import 'package:flutter/material.dart';
import 'screens/mapa_gastronomico_screen.dart';

void main() {
  runApp(const MiAppGastronomia());
}

class MiAppGastronomia extends StatelessWidget {
  const MiAppGastronomia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutas Gastronómicas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const MapaGastronomicoScreen(),
    );
  }
}