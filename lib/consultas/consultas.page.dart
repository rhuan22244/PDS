import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'Consulta.dart' as consulta_model;
import 'MarcarConsultaPage.dart';
import 'editarConsultasPage.dart';

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  _ConsultasPageState createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  List<consulta_model.Consulta> consultasAgendadas = [];
  List<consulta_model.Consulta> consultasFinalizadas = [];
  List<consulta_model.Consulta> consultasCanceladas = [];
  List<consulta_model.Consulta> consultasFiltradas = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConsultas();
    _searchController.addListener(_filterConsultas);
  }

  Future<void> _loadConsultas() async {
    final todasConsultas = await DatabaseHelper.instance.getConsultas();
    if (!mounted) return;
    setState(() {
      consultasAgendadas = todasConsultas
          .where((c) => c.status == 'Agendada')
          .toList();
      consultasFinalizadas = todasConsultas
          .where((c) => c.status == 'Finalizada')
          .toList();
      consultasCanceladas = todasConsultas
          .where((c) => c.status == 'Cancelada')
          .toList();
      consultasFiltradas = consultasAgendadas;
    });
  }

  void _filterConsultas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      consultasFiltradas = consultasAgendadas
          .where((consulta) =>
      consulta.especialidade.toLowerCase().contains(query) ||
          consulta.local.toLowerCase().contains(query))
          .toList();
    });
  }

  void _adicionarConsulta(consulta_model.Consulta consulta) async {
    await DatabaseHelper.instance.insertConsulta(consulta);
    _loadConsultas();
  }

  Future<bool?> _confirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarConsulta(consulta_model.Consulta consulta) async {
    final confirmed = await _confirmDialog(
      'Confirmar Cancelamento',
      'Tem certeza que deseja cancelar esta consulta?',
    );

    if (confirmed == true) {
      consulta.status = 'Cancelada';
      await DatabaseHelper.instance.updateConsulta(consulta);
      _loadConsultas();
    }
  }

  Future<void> _finalizarConsulta(consulta_model.Consulta consulta) async {
    final confirmed = await _confirmDialog(
      'Confirmar Finalização',
      'Tem certeza que deseja finalizar esta consulta?',
    );

    if (confirmed == true) {
      consulta.status = 'Finalizada';
      await DatabaseHelper.instance.updateConsulta(consulta);
      _loadConsultas();
    }
  }

  Future<void> _excluirConsulta(consulta_model.Consulta consulta) async {
    final confirmed = await _confirmDialog(
      'Excluir Consulta',
      'Tem certeza que deseja excluir esta consulta? Esta ação é irreversível.',
    );

    if (confirmed == true) {
      if (consulta.id != null) {
        await DatabaseHelper.instance.deleteConsulta(consulta.id!);
        _loadConsultas();
      } else {
        print('Erro: Consulta sem ID não pode ser excluída.');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'Consultas',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'AGENDADAS'),
              Tab(text: 'FINALIZADAS'),
              Tab(text: 'CANCELADAS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ConsultasTab(
              consultas: consultasFiltradas,
              searchController: _searchController,
              onCancelarConsulta: _cancelarConsulta,
              onFinalizarConsulta: _finalizarConsulta,
              onExcluirConsulta: _excluirConsulta,
              onMarcarConsulta: _adicionarConsulta,
              loadConsultas: _loadConsultas,
              mostrarBusca: true,
            ),
            _ConsultasTab(
              consultas: consultasFinalizadas,
              onExcluirConsulta: _excluirConsulta,
              loadConsultas: _loadConsultas,
              mostrarBusca: false,
            ),
            _ConsultasTab(
              consultas: consultasCanceladas,
              onExcluirConsulta: _excluirConsulta,
              loadConsultas: _loadConsultas,
              mostrarBusca: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultasTab extends StatelessWidget {
  final List<consulta_model.Consulta> consultas;
  final Future<void> Function(consulta_model.Consulta)? onCancelarConsulta;
  final Future<void> Function(consulta_model.Consulta)? onFinalizarConsulta;
  final Future<void> Function(consulta_model.Consulta)? onExcluirConsulta;
  final void Function(consulta_model.Consulta)? onMarcarConsulta;
  final Future<void> Function()? loadConsultas;
  final TextEditingController? searchController;
  final bool mostrarBusca;

  const _ConsultasTab({
    required this.consultas,
    this.onCancelarConsulta,
    this.onFinalizarConsulta,
    this.onExcluirConsulta,
    this.onMarcarConsulta,
    this.loadConsultas,
    this.searchController,
    required this.mostrarBusca,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (mostrarBusca)
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar consulta...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: consultas.isEmpty
                ? const Center(child: Text('Nenhuma consulta disponível'))
                : ListView.builder(
              itemCount: consultas.length,
              itemBuilder: (context, index) {
                final consulta = consultas[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarConsultaPage(
                          id: consulta.id!,
                          especialidade: consulta.especialidade,
                          local: consulta.local,
                          data: consulta.data,
                          hora: consulta.hora,
                          status: consulta.status,
                        ),
                      ),
                    ).then((_) => loadConsultas?.call());
                  },
                  child: _ConsultaCard(
                    especialidade: consulta.especialidade,
                    local: consulta.local,
                    data: consulta.data,
                    hora: consulta.hora,
                    status: consulta.status,
                    onCancelar: onCancelarConsulta != null &&
                        consulta.status == 'Agendada'
                        ? () => onCancelarConsulta!(consulta)
                        : null,
                    onFinalizar: onFinalizarConsulta != null &&
                        consulta.status == 'Agendada'
                        ? () => onFinalizarConsulta!(consulta)
                        : null,
                    onExcluir: onExcluirConsulta != null &&
                        (consulta.status == 'Cancelada' ||
                            consulta.status == 'Finalizada')
                        ? () => onExcluirConsulta!(consulta)
                        : null,
                  ),
                );
              },
            ),
          ),
          if (onMarcarConsulta != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarcarConsultaPage(
                      onConsultaMarcada: (consulta) {
                        onMarcarConsulta!(consulta);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Marcar Consulta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsultaCard extends StatelessWidget {
  final String especialidade;
  final String local;
  final String data;
  final String hora;
  final String status;
  final VoidCallback? onCancelar;
  final VoidCallback? onFinalizar;
  final VoidCallback? onExcluir;

  const _ConsultaCard({
    required this.especialidade,
    required this.local,
    required this.data,
    required this.hora,
    required this.status,
    this.onCancelar,
    this.onFinalizar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    especialidade,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 4),
            Text(local),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 4),
                Text(data),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 4),
                Text(hora),
                const Spacer(),
                Expanded(
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onCancelar != null)
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: onCancelar,
                    color: Colors.orange,
                    tooltip: 'Cancelar Consulta',
                  ),
                if (onFinalizar != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    onPressed: onFinalizar,
                    color: Colors.green,
                    tooltip: 'Finalizar Consulta',
                  ),
                if (onExcluir != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onExcluir,
                    color: Colors.red,
                    tooltip: 'Excluir Consulta',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






















































