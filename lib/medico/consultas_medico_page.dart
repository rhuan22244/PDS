import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultasMedicoPage extends StatelessWidget {
  final String medicoId;

  const ConsultasMedicoPage({super.key, required this.medicoId});

  get connectionState => null;

  Future<void> _excluirConsulta(String consultaId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Consultas')
          .doc(consultaId)
          .delete();
    } catch (e) {
      print('Erro ao excluir consulta: $e');
    }
  }

  Future<bool?> _mostrarDialogoDeConfirmacao(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza que deseja apagar esta consulta permanentemente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Retorna falso se cancelar
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Retorna true se confirmar
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> atualizarStatusConsulta(String consultaId, String novoStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Consultas')
          .doc(consultaId)
          .update({'status': novoStatus});
    } catch (e) {
      print('Erro ao atualizar status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Consultas"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Consultas')
            .where('medicoId', isEqualTo: medicoId)
            .orderBy('data')
            .orderBy('hora')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Ocorreu um erro ao carregar as consultas."));
          }
          if (connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final consultas = snapshot.data?.docs ?? [];
          if (consultas.isEmpty) {
            return const Center(child: Text("Nenhuma consulta encontrada."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: consultas.length,
            itemBuilder: (context, index) {
              final doc = consultas[index];
              final consulta = doc.data() as Map<String, dynamic>;

              final status = consulta['status'] ?? 'Desconhecido';
              final especialidade = consulta['especialidade'] ?? 'Especialidade';
              final data = consulta['data'] ?? 'Data';
              final hora = consulta['hora'] ?? 'Hora';
              final pacienteNome = consulta['pacienteNome'] ?? 'Paciente não identificado';

              Color statusColor;
              switch (status) {
                case 'Agendada': statusColor = Colors.green; break;
                case 'Finalizada': statusColor = Colors.blue; break;
                case 'Cancelada': statusColor = Colors.red; break;
                default: statusColor = Colors.grey;
              }

              return Dismissible(
                key: Key(doc.id),

                direction: DismissDirection.startToEnd,

                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                confirmDismiss: (direction) async {
                  final confirmado = await _mostrarDialogoDeConfirmacao(context);
                  return confirmado ?? false;
                },

                onDismissed: (direction) {
                  _excluirConsulta(doc.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Consulta com $pacienteNome excluída')),
                  );
                },

                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(especialidade, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Paciente: $pacienteNome\nData: $data às $hora',
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'Finalizar') {
                          await atualizarStatusConsulta(doc.id, 'Finalizada');
                        } else if (value == 'Cancelar') {
                          await atualizarStatusConsulta(doc.id, 'Cancelada');
                        }
                      },
                      itemBuilder: (context) => [
                        if (status == 'Agendada')
                          const PopupMenuItem(value: 'Finalizar', child: Text('Finalizar')),
                        if (status == 'Agendada')
                          const PopupMenuItem(value: 'Cancelar', child: Text('Cancelar')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}






