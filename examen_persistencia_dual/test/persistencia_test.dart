import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:examen_persistencia_dual/elemento_model.dart';
import 'package:examen_persistencia_dual/elemento_repository.dart';
import 'package:examen_persistencia_dual/sql_repository.dart';
import 'package:examen_persistencia_dual/nosql_repository.dart';

void main() {
  // Configuración inicial para permitir que SQLite corra en las pruebas locales de la PC
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Suite de Pruebas Unitarias - Persistencia Dual', () {

    // TEST 1: Validar el comportamiento del motor Relacional (SQL)
    test('Prueba 1: Escala de escritura y lectura en Motor SQL', () async {
      final ElementoRepository repository = SqlRepository();

      final nuevoElemento = ElementoModel(
        titulo: 'Nota SQL Test',
        descripcion: 'Guardado estructurado en tablas',
      );

      await repository.insertar(nuevoElemento);
      final lista = await repository.obtenerTodos();

      expect(lista.isNotEmpty, true);
      expect(lista.any((e) => e.titulo == 'Nota SQL Test'), true);
    });

    // TEST 2: Validar el comportamiento del motor No Relacional (NoSQL)
    test('Prueba 2: Validación de persistencia dinámica en Motor NoSQL', () async {
      final ElementoRepository repository = NoSqlRepository();

      final nuevoDocumento = ElementoModel(
        titulo: 'Documento NoSQL Test',
        descripcion: 'Guardado dinámico en JSON',
      );

      await repository.insertar(nuevoDocumento);
      final lista = await repository.obtenerTodos();

      expect(lista.isNotEmpty, true);
      expect(lista.any((e) => e.titulo == 'Documento NoSQL Test'), true);
    });
  });
}