import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../consultas/Consulta.dart';

class DatabaseHelper {
  // Singleton para garantir uma única instância do banco
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Getter para o banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  // Inicializa/cria o banco
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Cria as tabelas
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE consultas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        especialidade TEXT NOT NULL,
        local TEXT NOT NULL,
        data TEXT NOT NULL,
        hora TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // Insere uma nova consulta e retorna o id gerado
  Future<int> insertConsulta(Consulta consulta) async {
    final db = await instance.database;
    final id = await db.insert(
      'consultas',
      consulta.toMap()..remove('id'), // Remove o id para autoincrementar
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // Busca todas as consultas
  Future<List<Consulta>> getConsultas() async {
    final db = await instance.database;
    final result = await db.query('consultas');
    return result.map((json) => Consulta.fromMap(json)).toList();
  }

  // Atualiza uma consulta pelo id
  Future<int> updateConsulta(Consulta consulta) async {
    final db = await instance.database;
    return db.update(
      'consultas',
      consulta.toMap(),
      where: 'id = ?',
      whereArgs: [consulta.id],
    );
  }

  // Deleta uma consulta pelo id
  Future<int> deleteConsulta(int id) async {
    final db = await instance.database;
    return await db.delete(
      'consultas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fecha o banco (opcional)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}







