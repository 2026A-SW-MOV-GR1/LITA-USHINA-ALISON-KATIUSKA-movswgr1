import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'elemento_model.dart';
import 'elemento_repository.dart';
import 'logger.dart';

class NoSqlRepository implements ElementoRepository {
  File? _archivoLocal;

  // Inicializa de forma ágil el archivo físico que actuará como documento NoSQL
  Future<File> get _file async {
    if (_archivoLocal != null) return _archivoLocal!;

    final directorioPath = await getDatabasesPath();
    final path = join(directorioPath, 'examen_nosql.json');
    _archivoLocal = File(path);

    // Si el archivo de colección documental no existe, se inicializa vacío
    if (!await _archivoLocal!.exists()) {
      AppLogger.debug('Sin Esquema Estricto NoSQL: Creando colección documental vacía en: $path');
      await _archivoLocal!.writeAsString(json.encode([]));
    }
    return _archivoLocal!;
  }

  @override
  Future<List<ElementoModel>> obtenerTodos() async {
    AppLogger.info('NoSQL: Leyendo colección completa de documentos JSON.');
    try {
      final archivo = await _file;
      final contenido = await archivo.readAsString();
      final List<dynamic> jsonList = json.decode(contenido);

      return jsonList.map((item) => ElementoModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('NoSQL: Error al parsear los documentos dinámicos.', e);
      return [];
    }
  }

  @override
  Future<void> insertar(ElementoModel elemento) async {
    AppLogger.info('NoSQL: Intentando insertar documento dinámico - ${elemento.titulo}');
    try {
      final archivo = await _file;
      final elementos = await obtenerTodos();

      // Simulación dinámica de ID autoincrementable para emparejar con la UI
      int nuevoId = elemento.id ?? (elementos.isEmpty ? 1 : (elementos.last.id ?? 0) + 1);

      final nuevoElemento = ElementoModel(
        id: nuevoId,
        titulo: elemento.titulo,
        descripcion: elemento.descripcion,
      );

      // Reemplaza si existe (UPDATE) o añade si es nuevo (CREATE)
      elementos.removeWhere((e) => e.id == nuevoId);
      elementos.add(nuevoElemento);

      // Serialización directa a formato JSON en disco
      final List<Map<String, dynamic>> mapaList = elementos.map((e) => e.toMap()).toList();
      await archivo.writeAsString(json.encode(mapaList));

      AppLogger.debug('NoSQL: Documento indexado con ID $nuevoId guardado con éxito.');
    } catch (e) {
      AppLogger.error('NoSQL: Fallo crítico al escribir documento.', e);
    }
  }

  @override
  Future<void> eliminar(int id) async {
    AppLogger.info('NoSQL: Intentando remover documento con ID: $id');
    try {
      final archivo = await _file;
      final elementos = await obtenerTodos();

      elementos.removeWhere((e) => e.id == id);

      final List<Map<String, dynamic>> mapaList = elementos.map((e) => e.toMap()).toList();
      await archivo.writeAsString(json.encode(mapaList));

      AppLogger.debug('NoSQL: Documento con ID $id eliminado de la colección.');
    } catch (e) {
      AppLogger.error('NoSQL: Error al eliminar documento con ID $id.', e);
    }
  }
}