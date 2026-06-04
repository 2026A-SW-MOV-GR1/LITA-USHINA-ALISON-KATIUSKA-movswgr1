import 'elemento_model.dart';

abstract class ElementoRepository {
  // Contrato para obtener la lista completa de elementos
  Future<List<ElementoModel>> obtenerTodos();

  // Contrato para insertar un nuevo elemento
  Future<void> insertar(ElementoModel elemento);

  // Contrato para eliminar un elemento mediante su ID
  Future<void> eliminar(int id);
}