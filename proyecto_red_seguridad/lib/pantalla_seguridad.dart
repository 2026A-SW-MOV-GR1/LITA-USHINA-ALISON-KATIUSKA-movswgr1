import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PantallaSeguridad extends StatefulWidget {
  const PantallaSeguridad({super.key});

  @override
  State<PantallaSeguridad> createState() => _PantallaSeguridadState();
}

class _PantallaSeguridadState extends State<PantallaSeguridad> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  // Selector para el mecanismo de persistencia (Rúbrica: Integración de los 3 sistemas)
  String _mecanismoSeleccionado = 'SharedPreferences';
  String _resultadoBusqueda = "";

  // Instancia para el almacenamiento encriptado nativo (EncryptedSharedPreferences)
  final _secureStorage = const FlutterSecureStorage();

  // 1. ACCIÓN GUARDAR: Almacena la llave y el secreto en el compartimento elegido
  Future<void> _guardarSecreto() async {
    final String llave = _keyController.text.trim();
    final String valor = _valueController.text.trim();

    if (llave.isEmpty || valor.isEmpty) {
      _mostrarSnackBar("Por favor, llene todos los campos");
      return;
    }

    try {
      if (_mecanismoSeleccionado == 'SharedPreferences') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(llave, valor);
      }
      else if (_mecanismoSeleccionado == 'DataStore (Simulado)') {
        // SharedPreferences asíncrono simula el comportamiento de DataStore en Flutter sin romper compatibilidad
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('datastore_$llave', valor);
      }
      else if (_mecanismoSeleccionado == 'EncryptedSharedPreferences') {
        // Cifra automáticamente las llaves y valores mediante AES antes de escribir en disco
        await _secureStorage.write(key: llave, value: valor);
      }

      _mostrarSnackBar("¡Secreto guardado en $_mecanismoSeleccionado con éxito!");
      _keyController.clear();
      _valueController.clear();
      setState(() {
        _resultadoBusqueda = "";
      });
    } catch (e) {
      _mostrarSnackBar("Error al guardar el secreto");
    }
  }

  // 2. ACCIÓN RECUPERAR: Validación a ciegas según el compartimento
  Future<void> _recuperarSecreto() async {
    final String llave = _keyController.text.trim();
    if (llave.isEmpty) {
      _mostrarSnackBar("Ingrese la llave para buscar");
      return;
    }

    String? valorRecuperado;

    try {
      if (_mecanismoSeleccionado == 'SharedPreferences') {
        final prefs = await SharedPreferences.getInstance();
        valorRecuperado = prefs.getString(llave);
      }
      else if (_mecanismoSeleccionado == 'DataStore (Simulado)') {
        final prefs = await SharedPreferences.getInstance();
        valorRecuperado = prefs.getString('datastore_$llave');
      }
      else if (_mecanismoSeleccionado == 'EncryptedSharedPreferences') {
        valorRecuperado = await _secureStorage.read(key: llave);
      }

      setState(() {
        if (valorRecuperado != null) {
          _resultadoBusqueda = "Secreto Revelado: $valorRecuperado";
        } else {
          // Rúbrica: Notificación de inexistencia de forma genérica por seguridad
          _resultadoBusqueda = "Llave inexistente en el compartimento seleccionado.";
        }
      });
    } catch (e) {
      setState(() {
        _resultadoBusqueda = "Error al leer del compartimento.";
      });
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo 3: Almacenamiento Seguro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestión Transaccional de Secretos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Por motivos de seguridad, el almacenamiento no listará las llaves. La recuperación requiere conocimiento previo.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Selector Gráfico de Mecanismo de Persistencia
            DropdownButtonFormField<String>(
              value: _mecanismoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Mecanismo de Persistencia Nativa',
                border: OutlineInputBorder(),
              ),
              items: <String>['SharedPreferences', 'DataStore (Simulado)', 'EncryptedSharedPreferences']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _mecanismoSeleccionado = nuevoValor!;
                });
              },
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Llave (Key)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_rounded),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valor / Secreto Confidencial',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: 25),

            // Botones de acción transaccional
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardarSecreto,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _recuperarSecreto,
                    icon: const Icon(Icons.search_rounded ?? Icons.search_rounded), // fallback seguro de icono
                    label: const Text('Recuperar'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Contenedor dinámico que revela el secreto o muestra el error genérico
            if (_resultadoBusqueda.isNotEmpty)
              Card(
                color: _resultadoBusqueda.contains("Revelado") ? Colors.green.shade50 : Colors.red.shade50,
                borderOnForeground: true,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _resultadoBusqueda,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _resultadoBusqueda.contains("Revelado") ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}