class Consulta {
  final int id;
  final String especialidade;
  final String local;
  final String data;
  final String hora;
  String status;

  Consulta({
    required this.id,
    required this.especialidade,
    required this.local,
    required this.data,
    required this.hora,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'especialidade': especialidade,
      'local': local,
      'data': data,
      'hora': hora,
      'status': status,
    };
  }

  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      id: map['id'],
      especialidade: map['especialidade'],
      local: map['local'],
      data: map['data'],
      hora: map['hora'],
      status: map['status'],
    );
  }
}



