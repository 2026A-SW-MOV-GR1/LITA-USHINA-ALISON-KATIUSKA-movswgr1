import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'elemento_model.dart';
import 'elemento_repository.dart';
import 'logger.dart';

class SqlRepository implements ElementoRepository {
  Database? _database;

  // Inicializa o retorna la conexión activa de SQLite
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Busca la ruta física del almacenamiento del teléfono
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'examen_sqlite.db');

    AppLogger.info('Inicializando Base de Datos SQLite en la ruta: $path');

    // Abre la base de datos y crea la tabla con esquema fijo
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE elementos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL
          )
        ''');
        AppLogger.debug('Esquema Estricto SQL: Tabla "elementos" creada con éxito.');
      },
    );
  }

  @override
  Future<List<ElementoModel>> obtenerTodos() async {
    AppLogger.info('SQL: Ejecutando consulta SELECT sobre la tabla elementos.');
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('elementos');

      return List.generate(maps.length, (i) {
        return ElementoModel.fromMap(maps[i]);
      });
    } catch (e) {
      AppLogger.error('SQL: Error al consultar los datos.', e);
      return [];
    }
  }

  @override
  Future<void> insertar(ElementoModel elemento) async {
    AppLogger.info('SQL: Intentando insertar registro - ${elemento.titulo}');
    try {
      final db = await database;
      await db.insert(
        'elementos',
        elemento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.debug('SQL: Registro insertado exitosamente en SQLite.');
    } catch (e) {
      AppLogger.error('SQL: Fallo crítico al insertar registro.', e);
    }
  }

  @override
  Future<void> eliminar(int id) async {
    AppLogger.info('SQL: Intentando eliminar registro con ID: $id');
    try {
      final db = await database;
      await db.delete(
        'elementos',
        where: 'id = ?',
        whereArgs: [id],
      );
      AppLogger.debug('SQL: Registro con ID $id eliminado de SQLite.');
    } catch (e) {
      AppLogger.error('SQL: Error al eliminar registro con ID $id.', e);
    }
  }
}