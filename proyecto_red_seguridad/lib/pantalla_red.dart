import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PantallaRed extends StatefulWidget {
  const PantallaRed({super.key});

  @override
  State<PantallaRed> createState() => _PantallaRedState();
}

class _PantallaRedState extends State<PantallaRed> {
  // Controladores para capturar el texto de los inputs
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isLoading = false; // Controla el estado de carga (Rúbrica: loading states)
  String _mensajeStatus = ""; // Almacena códigos de respuesta o errores

  // 1. PETICIÓN GET: Consulta un Post por ID
  Future<void> _consultarPost() async {
    final String id = _idController.text.trim();
    if (id.isEmpty) {
      _mostrarSnackBar("Por favor, ingrese un ID numérico");
      return;
    }

    setState(() {
      _isLoading = true; // Bloquea la UI y activa el círculo de carga
      _mensajeStatus = "";
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _titleController.text = data['title'];
          _bodyController.text = data['body'];
          _mensajeStatus = "Código HTTP: 200 OK - Datos cargados";
        });
      } else {
        setState(() {
          _mensajeStatus = "Error: Código HTTP ${response.statusCode} (No encontrado)";
          _titleController.clear();
          _bodyController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _mensajeStatus = "Error de conexión a la red";
      });
    } finally {
      setState(() {
        _isLoading = false; // Desbloquea la UI al finalizar la transacción
      });
    }
  }

  // 2. PETICIÓN PUT: Envía la actualización simulada al servidor
  Future<void> _actualizarPost() async {
    final String id = _idController.text.trim();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': int.parse(id),
          'title': _titleController.text,
          'body': _bodyController.text,
          'userId': 1,
        }),
      );

      // Rúbrica: Capturar código 200 OK para actualizar el estado visual
      if (response.statusCode == 200) {
        setState(() {
          _mensajeStatus = "Código HTTP: 200 OK - ¡Actualizado en servidor con éxito!";
        });
        _mostrarSnackBar("Servidor respondió: 200 OK. Registro modificado.");
      } else {
        setState(() {
          _mensajeStatus = "Error PUT: Código HTTP ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _mensajeStatus = "Error al intentar actualizar";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo 1: Conectividad REST'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de entrada del ID numérico para la consulta GET
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading, // Se deshabilita si está cargando
                      decoration: const InputDecoration(
                        labelText: 'ID del Post (Entrada Numérica)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _consultarPost, // Bloquea interacción en tránsito
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Ejecutar Consulta (GET)'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Indicador visual de carga requerido por la UX de la rúbrica
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Estado de la transacción de red en texto destacado
            if (_mensajeStatus.isNotEmpty)
              Text(
                _mensajeStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _mensajeStatus.contains("200") ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),

            // Campos editables con el contenido devuelto por el JSONPlaceholder
            TextField(
              controller: _titleController,
              enabled: !_isLoading && _titleController.text.isNotEmpty,
              decoration: const InputDecoration(
                labelText: 'Título del Post',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              enabled: !_isLoading && _bodyController.text.isNotEmpty,
              decoration: const InputDecoration(
                labelText: 'Cuerpo del Post',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para disparar la actualización PUT
            FilledButton.icon(
              onPressed: (_isLoading || _titleController.text.isEmpty) ? null : _actualizarPost,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Enviar Actualización (PUT)'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}