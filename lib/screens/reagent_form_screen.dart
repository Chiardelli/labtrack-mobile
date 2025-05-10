import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReagentFormScreen extends StatefulWidget {
  const ReagentFormScreen({super.key});

  @override
  State<ReagentFormScreen> createState() => _ReagentFormScreenState();
}

class _ReagentFormScreenState extends State<ReagentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  DateTime? _expiryDate;
  String? _selectedType;
  String? _selectedUnit;
  bool _isSubmitting = false;

  final List<String> _reagentTypes = [
    'Ácido',
    'Base',
    'Solvente',
    'Indicador',
    'Sal Inorgânico',
    'Outro'
  ];

  final List<String> _unitTypes = ['mL', 'L', 'g', 'kg', 'mg', 'unidades'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0061A8),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E3A47),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0061A8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('reagents').add({
        'name': _nameController.text.trim(),
        'batch': _batchController.text.trim(),
        'type': _selectedType,
        'quantity': '${_quantityController.text.trim()} ${_selectedUnit ?? 'mL'}',
        'expiry': _expiryDate,
        'location': _locationController.text.trim(),
        'responsible': _responsibleController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _responsibleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Reagente'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'Informações do Reagente'),
              _buildFormField(
                label: 'Nome do Reagente*',
                hint: 'Ex: Ácido Clorídrico',
                controller: _nameController,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.science,
                isRequired: true,
              ),
              _buildFormField(
                label: 'Número do Lote*',
                hint: 'Ex: LOTE-2024-001',
                controller: _batchController,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.tag,
                isRequired: true,
              ),
              _buildDropdown(
                label: 'Tipo de Reagente*',
                value: _selectedType,
                items: _reagentTypes,
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'Selecione um tipo' : null,
                icon: Icons.category,
                isRequired: true,
              ),

              const _SectionHeader(title: 'Controle de Estoque'),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildFormField(
                      label: 'Quantidade*',
                      hint: 'Ex: 500',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Campo obrigatório';
                        if (double.tryParse(value) == null) return 'Número inválido';
                        return null;
                      },
                      icon: Icons.scale,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _buildDropdown(
                      label: 'Unidade*',
                      value: _selectedUnit,
                      items: _unitTypes,
                      onChanged: (value) => setState(() => _selectedUnit = value),
                      validator: (value) => value == null ? 'Selecione' : null,
                      icon: Icons.straighten,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              _buildDateField(),

              const _SectionHeader(title: 'Localização'),
              _buildFormField(
                label: 'Local no Laboratório',
                hint: 'Ex: Armário 3, Prateleira B',
                controller: _locationController,
                icon: Icons.location_on,
                validator: (value) => null, // Campo não obrigatório
              ),
              _buildFormField(
                label: 'Responsável*',
                hint: 'Nome do responsável',
                controller: _responsibleController,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.person,
                isRequired: true,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0061A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'CADASTRAR REAGENTE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E3A47),
                fontSize: 14,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: icon != null
                  ? Icon(icon, color: const Color(0xFF0061A8))
                  : null,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E3A47),
                fontSize: 14,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF0061A8)),
            ),
            hint: const Text('Selecione'),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data de Validade*',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3A47),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(10),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF0061A8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _expiryDate == null
                        ? 'Selecione uma data'
                        : DateFormat('dd/MM/yyyy').format(_expiryDate!),
                    style: TextStyle(
                      color: _expiryDate == null
                          ? Colors.grey[500]
                          : Colors.black,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0061A8),
        ),
      ),
    );
  }
}