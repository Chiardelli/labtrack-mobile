import 'package:flutter/material.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';

class ReagentEditScreen extends StatefulWidget {
  final Reagent reagent;

  const ReagentEditScreen({super.key, required this.reagent});

  @override
  State<ReagentEditScreen> createState() => _ReagentEditScreenState();
}

class _ReagentEditScreenState extends State<ReagentEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descricaoController;
  late TextEditingController _fornecedorController;
  late TextEditingController _quantidadeController;

  late String _unidadeSelecionada;
  late String _tipoItemSelecionado;
  late String _classificacaoRiscoSelecionada;
  String? _orgaoReguladorSelecionado;

  // Listas de opções (substitua conforme seu modelo)
  final List<String> unidades = ['ML', 'L', 'MG', 'G', 'KG'];
  final List<String> tiposItem = [
    'ACIDO',
    'BASE',
    'SOLVENTE',
    'INDICADOR',
    'SAL_INORGANICO',
    'OUTRO',
  ];
  final List<String> classificacoesRisco = ['SEGURO', 'ATENCAO', 'PERIGO'];
  final List<String> orgaosReguladores = [
    'POLICIA_FEDERAL', // Controle de substâncias químicas controladas e precursores
    'EXERCITO_BRASILEIRO', // Controle e fiscalização de produtos químicos estratégicos e potencialmente perigosos
    'ANVISA', // Vigilância sanitária de produtos químicos para saúde e alimentos
    'IBAMA', // Controle ambiental
    'MAPA', // Regulação de produtos químicos agrícolas
    'ANP', // Regulação química na indústria de petróleo e gás
    'MTE', // Normas de segurança do trabalho com químicos
    'ISO', // Normas internacionais (não é órgão regulador, mas norma técnica),
  ];

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.reagent.descricao,
    );
    _fornecedorController = TextEditingController(
      text: widget.reagent.fornecedor,
    );
    _quantidadeController = TextEditingController(
      text: widget.reagent.quantidade.toString(),
    );

    // Inicializa as seleções com os valores atuais do reagente
    _unidadeSelecionada = widget.reagent.unidade.toString().split('.').last;
    _tipoItemSelecionado = widget.reagent.tipoItem.toString().split('.').last;
    _classificacaoRiscoSelecionada =
        widget.reagent.classificacaoRisco.toString().split('.').last;
    _orgaoReguladorSelecionado = widget.reagent.orgaoRegulador;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _fornecedorController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final updatedReagent = Reagent(
        codigoItem: widget.reagent.codigoItem,
        descricao: _descricaoController.text,
        fornecedor: _fornecedorController.text,
        qrCodeImageUrl: widget.reagent.qrCodeImageUrl,
        tipoItem: TipoItem.values.firstWhere(
          (e) => e.toString().split('.').last == _tipoItemSelecionado,
        ),
        quantidade: double.tryParse(_quantidadeController.text) ?? 0.0,
        unidade: Unidade.values.firstWhere(
          (e) => e.toString().split('.').last == _unidadeSelecionada,
        ),
        locLaboratorio: widget.reagent.locLaboratorio,
        possuiOrgaoRegulador: widget.reagent.possuiOrgaoRegulador,
        orgaoRegulador: _orgaoReguladorSelecionado ?? 'Não possui',
        condicoesArmazenamento: widget.reagent.condicoesArmazenamento,
        classificacaoRisco: ClassificacaoRisco.values.firstWhere(
          (e) => e.toString().split('.').last == _classificacaoRiscoSelecionada,
        ),
        dataFabricacao: widget.reagent.dataFabricacao,
        dataVencimento: widget.reagent.dataVencimento,
        dataRegistro: widget.reagent.dataRegistro,
      );

      Navigator.pop(context, updatedReagent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reagente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _fornecedorController,
                decoration: const InputDecoration(labelText: 'Fornecedor'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _unidadeSelecionada,
                items:
                    unidades.map((unidade) {
                      return DropdownMenuItem<String>(
                        value: unidade,
                        child: Text(unidade),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _unidadeSelecionada = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Unidade de Medida',
                ),
              ),

              DropdownButtonFormField<String>(
                value: _tipoItemSelecionado,
                items:
                    tiposItem.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoItemSelecionado = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de Item'),
              ),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Local do Laboratório',
                ),
                readOnly: true,
                initialValue: widget.reagent.locLaboratorio,
              ),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Condições de Armazenamento',
                ),
                readOnly: true,
                initialValue: widget.reagent.condicoesArmazenamento,
              ),

              DropdownButtonFormField<String>(
                value:
                    unidades.contains(_unidadeSelecionada)
                        ? _unidadeSelecionada
                        : null,
                items:
                    unidades.map((unidade) {
                      return DropdownMenuItem<String>(
                        value: unidade,
                        child: Text(unidade),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _unidadeSelecionada = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Unidade de Medida',
                ),
              ),

              DropdownButtonFormField<String>(
                value:
                    tiposItem.contains(_tipoItemSelecionado)
                        ? _tipoItemSelecionado
                        : null,
                items:
                    tiposItem.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoItemSelecionado = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de Item'),
              ),

              DropdownButtonFormField<String>(
                value:
                    classificacoesRisco.contains(_classificacaoRiscoSelecionada)
                        ? _classificacaoRiscoSelecionada
                        : null,
                items:
                    classificacoesRisco.map((risco) {
                      return DropdownMenuItem<String>(
                        value: risco,
                        child: Text(risco),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _classificacaoRiscoSelecionada = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Classificação de Risco',
                ),
              ),

              if (widget.reagent.possuiOrgaoRegulador)
                DropdownButtonFormField<String>(
                  value:
                      _orgaoReguladorSelecionado != null &&
                              orgaosReguladores.contains(
                                _orgaoReguladorSelecionado,
                              )
                          ? _orgaoReguladorSelecionado
                          : null,
                  items:
                      orgaosReguladores.map((orgao) {
                        return DropdownMenuItem<String>(
                          value: orgao,
                          child: Text(orgao),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _orgaoReguladorSelecionado = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Órgão Regulador',
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
