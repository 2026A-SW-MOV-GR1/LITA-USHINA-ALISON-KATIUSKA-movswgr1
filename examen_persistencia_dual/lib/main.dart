import 'package:flutter/material.dart';
import 'elemento_model.dart';
import 'elemento_repository.dart';
import 'sql_repository.dart';
import 'nosql_repository.dart';
import 'logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Examen Persistencia Dual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6D597A), // Mantenemos tu paleta pastel distintiva
      ),
      home: const PantallaCrudExamen(),
    );
  }
}

class PantallaCrudExamen extends StatefulWidget {
  const PantallaCrudExamen({super.key});

  @override
  State<PantallaCrudExamen> createState() => _PantallaCrudExamenState();
}

class _PantallaCrudExamenState extends State<PantallaCrudExamen> {
  // Instancias de los dos motores disponibles bajo el Patrón Repositorio
  final ElementoRepository _sqlRepo = SqlRepository();
  final ElementoRepository _noSqlRepo = NoSqlRepository();

  // Controladores para capturar los datos del formulario emergente
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Estado del mecanismo de conmutación (false = SQLite / true = NoSQL)
  bool _esNoSql = false;
  List<ElementoModel> _elementosCargados = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosSegunMotor(); // Carga inicial al encender la app
  }

  // Carga reactiva de los datos dependiendo exclusivamente de la posición del Switch
  Future<void> _cargarDatosSegunMotor() async {
    ElementoRepository motorActivo = _esNoSql ? _noSqlRepo : _sqlRepo;
    String nombreMotor = _esNoSql ? "NoSQL (JSON)" : "Relacional (SQLite)";

    AppLogger.debug('Conmutación en caliente detectada. Cambiando UI hacia: $nombreMotor');

    final datos = await motorActivo.obtenerTodos();
    setState(() {
      _elementosCargados = datos;
    });
  }

  // Dispara la acción de guardar un registro en el motor que esté activo en ese milisegundo
  Future<void> _guardarElemento() async {
    if (_tituloController.text.trim().isEmpty || _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    final nuevoElemento = ElementoModel(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
    );

    ElementoRepository motorActivo = _esNoSql ? _noSqlRepo : _sqlRepo;
    await motorActivo.insertar(nuevoElemento);

    _tituloController.clear();
    _descripcionController.clear();
    Navigator.of(context).pop(); // Cierra el formulario flotante

    _cargarDatosSegunMotor(); // Refresca la lista de forma instantánea
  }

  // Dispara la eliminación de un registro en el motor que esté seleccionado
  Future<void> _eliminarElemento(int id) async {
    ElementoRepository motorActivo = _esNoSql ? _noSqlRepo : _sqlRepo;
    await motorActivo.eliminar(id);
    _cargarDatosSegunMotor(); // Refresca la lista de forma instantánea
  }

  // Despliega un modal emergente limpio (Bottom Sheet) para el formulario de inserción
  void _mostrarFormularioFlotante() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Añadir a ${_esNoSql ? "NoSQL" : "SQLite"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título del Registro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descripcionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción / Detalle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarElemento,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
              child: const Text('Confirmar Inserción'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examen: Persistencia Dual', style: TextStyle(fontSize: 18)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // REQUISITO: Control Switch en App Bar para la conmutación en caliente
          Row(
            children: [
              const Icon(Icons.storage_rounded, size: 18),
              Switch(
                value: _esNoSql,
                onChanged: (bool valorNuevo) {
                  setState(() {
                    _esNoSql = valorNuevo;
                  });
                  _cargarDatosSegunMotor(); // REQUISITO: Reactividad instantánea al alternar
                },
              ),
              const Text('NoSQL ', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // REQUISITO: Indicador de Origen Activo mediante un Chip visual destacado
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Origen de Lectura actual: ', style: TextStyle(fontSize: 14)),
                InputChip(
                  label: Text(_esNoSql ? 'CONMUTADO: NoSQL (JSON)' : 'ACTIVO: SQLite (SQL)'),
                  avatar: Icon(
                    _esNoSql ? Icons.schema_rounded : Icons.table_rows_rounded,
                    color: _esNoSql ? Colors.orange.shade800 : Colors.blue.shade800,
                  ),
                  backgroundColor: _esNoSql ? Colors.orange.shade50 : Colors.blue.shade50,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Listado reactivo de datos
          Expanded(
            child: _elementosCargados.isEmpty
                ? const Center(
              child: Text(
                'No hay registros guardados en este motor.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _elementosCargados.length,
              itemBuilder: (context, index) {
                final item = _elementosCargados[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text('${item.id ?? index}'),
                    ),
                    title: Text(item.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.descripcion),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () => _eliminarElemento(item.id!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botón flotante para invocar el formulario de inserción
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormularioFlotante,
        icon: const Icon(Icons.add_rounded),
        label: Text('Añadir a ${_esNoSql ? "NoSQL" : "SQLite"}'),
      ),
    );
  }
}
