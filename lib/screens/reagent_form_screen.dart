import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/services/auth_service.dart';
import 'package:labtrack_mobile/utils/api_config.dart';

class ReagentFormScreen extends StatefulWidget {
  const ReagentFormScreen({super.key});

  @override
  State<ReagentFormScreen> createState() => _ReagentFormScreenState();
}

class _ReagentFormScreenState extends State<ReagentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _fornecedorController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _locLaboratorioController = TextEditingController();
  final _condicoesController = TextEditingController();

  DateTime? _dataFabricacao;
  DateTime? _dataVencimento;
  TipoItem? _selectedTipoItem;
  Unidade? _selectedUnidade;
  ClassificacaoRisco? _selectedClassificacaoRisco;
  bool _isSubmitting = false;
  bool _possuiOrgaoRegulador = false;
  OrgaoRegulador? _selectedOrgaoRegulador;

  final AuthService _authService = AuthService();

  Future<void> _selectDate(BuildContext context, bool isFabricacao) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

    if (picked != null) {
      setState(() {
        if (isFabricacao) {
          _dataFabricacao = picked;
        } else {
          _dataVencimento = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataFabricacao == null ||
        _selectedTipoItem == null ||
        _selectedUnidade == null ||
        _selectedClassificacaoRisco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    if (_possuiOrgaoRegulador && _selectedOrgaoRegulador == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o órgão regulador')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada. Faça login novamente.'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/inventario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'descricao': _descricaoController.text.trim(),
          'fornecedor': _fornecedorController.text.trim(),
          'tipoItem': _selectedTipoItem!.name,
          'quantidade': double.parse(_quantidadeController.text.trim()),
          'unidade': _selectedUnidade!.name,
          'locLaboratorio': _locLaboratorioController.text.trim(),
          'condicoesArmazenamento': _condicoesController.text.trim(),
          'classificacaoRisco': _selectedClassificacaoRisco!.name,
          'dataFabricacao': DateFormat('yyyy-MM-dd').format(_dataFabricacao!),
          'dataVencimento':
              _dataVencimento != null
                  ? DateFormat('yyyy-MM-dd').format(_dataVencimento!)
                  : null,
          'possuiOrgaoRegulador': _possuiOrgaoRegulador,
          'orgaoRegulador':
              _possuiOrgaoRegulador ? _selectedOrgaoRegulador!.name : null,
        }),
      );

      if (response.statusCode == 401) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          await _submitForm();
          return;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sessão expirada. Faça login novamente.'),
              ),
            );
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }
      }

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reagente cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Falha ao cadastrar reagente');
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastrar Reagente',
          style: TextStyle(
            fontFamily:
                'Poppins', // nome da fonte customizada (se você tiver importado)
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
              const Text(
                'Informações Básicas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0061A8),
                ),
              ),
              const SizedBox(height: 16),

              // Descrição
              _buildFormField(
                label: 'Descrição*',
                hint: 'Ex: Ácido Clorídrico P.A.',
                controller: _descricaoController,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.description,
              ),

              // Fornecedor
              _buildFormField(
                label: 'Fornecedor*',
                hint: 'Ex: Sigma-Aldrich',
                controller: _fornecedorController,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.business,
              ),

              // Tipo de Item
              _buildDropdown<TipoItem>(
                label: 'Tipo de Item*',
                hint: 'Selecione o tipo',
                value: _selectedTipoItem,
                items: TipoItem.values,
                onChanged: (v) => setState(() => _selectedTipoItem = v),
                validator: (v) => v == null ? 'Selecione um tipo' : null,
                icon: Icons.category,
                displayText: (item) => item.toString().split('.').last,
              ),

              const SizedBox(height: 24),
              const Text(
                'Controle de Estoque',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0061A8),
                ),
              ),
              const SizedBox(height: 16),

              // Quantidade e Unidade
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildFormField(
                      label: 'Quantidade*',
                      hint: 'Ex: 500',
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Campo obrigatório';
                        if (double.tryParse(v) == null) return 'Valor inválido';
                        return null;
                      },
                      icon: Icons.scale,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _buildDropdown<Unidade>(
                      label: 'Unidade*',
                      hint: 'Selecione',
                      value: _selectedUnidade,
                      items: Unidade.values,
                      onChanged: (v) => setState(() => _selectedUnidade = v),
                      validator:
                          (v) => v == null ? 'Selecione uma unidade' : null,
                      icon: Icons.straighten,
                      displayText: (item) => item.name,
                    ),
                  ),
                ],
              ),

              // Local no Laboratório
              _buildFormField(
                label: 'Local no Laboratório*',
                hint: 'Ex: Armário 3, Prateleira B',
                controller: _locLaboratorioController,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.location_on,
              ),

              // Condições de Armazenamento
              _buildFormField(
                label: 'Condições de Armazenamento*',
                hint: 'Ex: Temperatura ambiente, protegido da luz',
                controller: _condicoesController,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                icon: Icons.storage,
              ),

              const SizedBox(height: 24),
              const Text(
                'Segurança',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0061A8),
                ),
              ),
              const SizedBox(height: 16),

              // Classificação de Risco
              _buildDropdown<ClassificacaoRisco>(
                label: 'Classificação de Risco*',
                hint: 'Selecione a classificação',
                value: _selectedClassificacaoRisco,
                items: ClassificacaoRisco.values,
                onChanged:
                    (v) => setState(() => _selectedClassificacaoRisco = v),
                validator:
                    (v) => v == null ? 'Selecione uma classificação' : null,
                icon: Icons.warning,
                displayText: (item) => item.toString().split('.').last,
              ),

              const SizedBox(height: 24),
              const Text(
                'Regulação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0061A8),
                ),
              ),
              const SizedBox(height: 16),

              // Possui órgão regulador
              SwitchListTile(
                title: const Text('Monitorado por órgão regulador?'),
                value: _possuiOrgaoRegulador,
                onChanged: (value) {
                  setState(() {
                    _possuiOrgaoRegulador = value;
                    if (!value) {
                      _selectedOrgaoRegulador = null;
                    }
                  });
                },
                activeColor: const Color(0xFF0061A8),
                secondary: const Icon(Icons.gavel, color: Color(0xFF0061A8)),
              ),

              // Órgão regulador
              if (_possuiOrgaoRegulador)
                _buildDropdown<OrgaoRegulador>(
                  label: 'Órgão Regulador*',
                  hint: 'Selecione o órgão',
                  value: _selectedOrgaoRegulador,
                  items: OrgaoRegulador.values,
                  onChanged: (v) => setState(() => _selectedOrgaoRegulador = v),
                  validator:
                      (v) =>
                          _possuiOrgaoRegulador && v == null
                              ? 'Selecione um órgão regulador'
                              : null,
                  icon: Icons.account_balance,
                  displayText: (item) => item.toString().split('.').last,
                ),

              const SizedBox(height: 24),
              const Text(
                'Datas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0061A8),
                ),
              ),
              const SizedBox(height: 16),

              // Data de Fabricação
              _buildDateField(
                label: 'Data de Fabricação*',
                value: _dataFabricacao,
                onTap: () => _selectDate(context, true),
              ),

              // Data de Vencimento (opcional)
              _buildDateField(
                label: 'Data de Vencimento',
                value: _dataVencimento,
                onTap: () => _selectDate(context, false),
                isRequired: false,
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
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'CADASTRAR REAGENTE',
                            style: TextStyle(
                              color: Colors.white,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3A47),
              fontSize: 14,
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
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon:
                  icon != null
                      ? Icon(icon, color: const Color(0xFF0061A8))
                      : null,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
    required IconData icon,
    required String Function(T) displayText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3A47),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF0061A8)),
            ),
            items:
                items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(displayText(item)),
                  );
                }).toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3A47),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
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
                    value == null
                        ? isRequired
                            ? 'Selecione uma data'
                            : 'Opcional'
                        : DateFormat('dd/MM/yyyy').format(value),
                    style: TextStyle(
                      color: value == null ? Colors.grey[500] : Colors.black,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (isRequired && value == null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Campo obrigatório',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

enum OrgaoRegulador {
  POLICIA_FEDERAL, // Controle de substâncias químicas controladas e precursores
  EXERCITO_BRASILEIRO, // Controle e fiscalização de produtos químicos estratégicos e potencialmente perigosos
  ANVISA, // Vigilância sanitária de produtos químicos para saúde e alimentos
  IBAMA, // Controle ambiental
  MAPA, // Regulação de produtos químicos agrícolas
  ANP, // Regulação química na indústria de petróleo e gás
  MTE, // Normas de segurança do trabalho com químicos
  ISO, // Normas internacionais (não é órgão regulador, mas norma técnica)
}
