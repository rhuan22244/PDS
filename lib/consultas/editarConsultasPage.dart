import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/database_helper.dart';
import 'Consulta.dart' as consulta_model;

class EditarConsultaPage extends StatefulWidget {
  final int id;
  final String especialidade;
  final String local;
  final String data;
  final String hora;
  final String status;

  const EditarConsultaPage({
    super.key,
    required this.id,
    required this.especialidade,
    required this.local,
    required this.data,
    required this.hora,
    required this.status,
  });

  @override
  _EditarConsultaPageState createState() => _EditarConsultaPageState();
}

class _EditarConsultaPageState extends State<EditarConsultaPage> {
  List<String> _especialidades = [];
  String? _especialidadeSelecionada;
  bool _carregandoEspecialidades = true;

  late TextEditingController _localController;
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _carregarEspecialidades();

    _localController = TextEditingController(text: widget.local);
    _dataController = TextEditingController(text: widget.data);
    _horaController = TextEditingController(text: widget.hora);
    _status = widget.status;
  }

  // Função auxiliar para normalizar strings (1ª letra maiúscula)
  String _formatar(String valor) {
    if (valor.isEmpty) return valor;
    return valor[0].toUpperCase() + valor.substring(1).toLowerCase();
  }

  Future<void> _carregarEspecialidades() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Especialidades').get();

      final especialidadesLidas = snapshot.docs
          .map((doc) => doc['Nome'].toString().trim())
          .map(_formatar)
          .toSet()
          .toList();

      final especialidadeFormatada = _formatar(widget.especialidade);

      setState(() {
        _especialidades = especialidadesLidas;
        _especialidadeSelecionada = _especialidades.contains(especialidadeFormatada)
            ? especialidadeFormatada
            : null;
        _carregandoEspecialidades = false;
      });

      print("Especialidade selecionada: $_especialidadeSelecionada");
      print("Itens disponíveis: $_especialidades");

    } catch (e) {
      setState(() {
        _carregandoEspecialidades = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar especialidades: $e')),
      );
    }
  }

  @override
  void dispose() {
    _localController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_especialidadeSelecionada == null ||
        _localController.text.isEmpty ||
        _dataController.text.isEmpty ||
        _horaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final consultaAtualizada = (
    id: widget.id,
    especialidade: _especialidadeSelecionada!,
    local: _localController.text,
    data: _dataController.text,
    hora: _horaController.text,
    );

    await DatabaseHelper.instance.updateConsulta(consultaAtualizada as consulta_model.Consulta);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Consulta'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _carregandoEspecialidades
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
              value: _especialidadeSelecionada,
              decoration: const InputDecoration(labelText: 'Especialidade'),
              items: _especialidades
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _especialidadeSelecionada = val;
                });
              },
              validator: (val) => val == null || val.isEmpty
                  ? 'Selecione uma especialidade'
                  : null,
            ),
            TextField(
              controller: _localController,
              decoration: const InputDecoration(labelText: 'Local'),
            ),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data (dd/mm/aaaa)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _horaController,
              decoration: const InputDecoration(labelText: 'Hora (hh:mm)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Agendada', 'Finalizada', 'Cancelada']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _status = val;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



















