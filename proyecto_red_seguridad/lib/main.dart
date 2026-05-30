import 'package:flutter/material.dart';
import 'pantalla_red.dart';
import 'pantalla_seguridad.dart';

void main() {
  runApp(const RedSeguridadApp());
}

class RedSeguridadApp extends StatelessWidget {
  const RedSeguridadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Red y Seguridad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6D597A), // Mantenemos tu paleta pastel
      ),
      home: const HomeNavegacion(),
    );
  }
}

class HomeNavegacion extends StatefulWidget {
  const HomeNavegacion({super.key});

  @override
  State<HomeNavegacion> createState() => _HomeNavegacionState();
}

class _HomeNavegacionState extends State<HomeNavegacion> {
  int _indiceActual = 0;

  // Lista de las dos pantallas independientes requeridas
  final List<Widget> _pantallas = [
    const PantallaRed(),
    const PantallaSeguridad(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_sync),
            label: 'Red REST',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Secretos',
          ),
        ],
      ),
    );
  }
}