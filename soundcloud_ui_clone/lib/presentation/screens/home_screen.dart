import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import '../widgets/trip_card_widget.dart';
import '../widgets/trip_tile_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Clasificamos los datos simulados para alimentar de forma independiente nuestras 3 listas (Fase B)
    final listServices = mockTrips.take(5).toList();       // Lista 1: Tipos de autos
    final listFrequent = mockTrips.skip(5).take(7).toList(); // Lista 2: Destinos frecuentes
    final listHistory = mockTrips.skip(12).toList();        // Lista 3: Historial reciente

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo claro característico de DiDi
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'DiDi Pasajero',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.help_outline, color: Colors.black),
          )
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ==========================================
          // SIMULACIÓN DE MAPA (Fidelidad Técnica sin WebViews)
          // ==========================================
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/600/300?random=map'), // Simulación visual de mapa de fondo
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(
                      '¿A dónde vamos hoy, Katy?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // LISTA 1: Horizontal (Carrusel de Servicios de Auto)
          // ==========================================
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Servicios disponibles',
              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16.0),
              itemCount: listServices.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TripCardWidget(trip: listServices[index]);
              },
            ),
          ),

          // ==========================================
          // LISTA 2: Vertical (Destinos Frecuentes)
          // ==========================================
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 6.0),
            child: Text(
              'Destinos frecuentes',
              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Cede el control del scroll al contenedor padre
            itemCount: listFrequent.length,
            itemBuilder: (context, index) {
              return TripTileWidget(trip: listFrequent[index], isHistory: false);
            },
          ),

          // ==========================================
          // LISTA 3: Vertical (Historial de Viajes Recientes)
          // ==========================================
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 6.0),
            child: Text(
              'Historial de viajes',
              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listHistory.length,
            itemBuilder: (context, index) {
              return TripTileWidget(trip: listHistory[index], isHistory: true);
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}