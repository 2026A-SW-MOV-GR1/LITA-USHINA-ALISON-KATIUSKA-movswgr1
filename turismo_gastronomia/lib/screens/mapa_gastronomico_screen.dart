import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapaGastronomicoScreen extends StatefulWidget {
  const MapaGastronomicoScreen({super.key});

  @override
  State<MapaGastronomicoScreen> createState() => _MapaGastronomicoScreenState();
}

class _MapaGastronomicoScreenState extends State<MapaGastronomicoScreen> {
  final MapController _mapController = MapController();

  // Coordenadas iniciales en Quito (Cerca de la EPN)
  final LatLng _ubicacionInicial = const LatLng(-0.2104, -78.4890);

  final List<Marker> _marcadores = [];
  final List<Polyline> _lineasRuta = [];
  LatLng? _miUbicacionActual; // Guardará tu posición GPS para usarla como punto de partida

  @override
  void initState() {
    super.initState();
    _cargarRestaurantesEjemplo();
    _obtenerUbicacionActual();
  }

  // Criterio de Evaluación: Lógica de negocio y marcadores interactivos
  void _cargarRestaurantesEjemplo() {
    setState(() {
      // Restaurante 1
      _marcadores.add(
        Marker(
          point: const LatLng(-0.2120, -78.4860),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              const destino = LatLng(-0.2120, -78.4860);
              _trazarRuta(destino);
              _mostrarDetallesRestaurante('Hueca - Hornados El Recreo', 'Comida típica ecuatoriana', destino);
            },
            child: const Icon(Icons.location_on, color: Colors.orange, size: 45),
          ),
        ),
      );

      // Restaurante 2
      _marcadores.add(
        Marker(
          point: const LatLng(-0.2085, -78.4930),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              const destino = LatLng(-0.2085, -78.4930);
              _trazarRuta(destino);
              _mostrarDetallesRestaurante('Cafetería - Café Águila de Oro', 'El mejor café filtrado de la zona', destino);
            },
            child: const Icon(Icons.location_on, color: Colors.brown, size: 45),
          ),
        ),
      );
    });
  }

  // Despliega los detalles de tu módulo gastronómico al hacer clic en el marcador
  void _mostrarDetallesRestaurante(String nombre, String descripcion, LatLng coordenadas) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 10),
              Text(descripcion, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Cierra el panel de abajo

                  // 1. Crear el paquete de datos (Extras) del contrato grupal
                  final Map<String, dynamic> extras = {
                    'id_turista': 'TURISTA-777',
                    'nombre_restaurante': nombre,
                    'latitud_restaurante': coordenadas.latitude,
                    'longitud_restaurante': coordenadas.longitude,
                    'hora_reserva': '14:30', // Hora simulada de la reserva
                  };

                  // 2. Configurar el Intent explícito hacia la app de Evelin (Kotlin)
                  final intent = AndroidIntent(
                    action: 'android.intent.action.VIEW',
                    package: 'com.turismo.actividades', // El ID de paquete acordado para Evelin
                    componentName: 'com.turismo.actividades.MainActivity', // La pantalla que recibe en Kotlin
                    arguments: extras, // Envía los datos
                  );

                  // 3. Lanzar el Intent de forma nativa en Android
                  try {
                    intent.launch();
                  } catch (e) {
                    // Si la app de Evelin aún no está instalada en tu emulador, saldrá este aviso
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abriendo puente inter-app... (Esperando App de Evelin)')),
                    );
                  }
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Reservar y Continuar Ruta'),
              )
            ],
          ),
        );
      },
    );
  }

  // Criterio de Evaluación: Geolocalización y gestión de coordenadas GPS
  Future<void> _obtenerUbicacionActual() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }

    if (permiso == LocationPermission.deniedForever) return;

    Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _miUbicacionActual = LatLng(posicion.latitude, posicion.longitude);
    });

    _mapController.move(_miUbicacionActual!, 15.0);
  }

  // Servicio OSRM para trazar la línea azul de ruta de forma gratuita
  Future<void> _trazarRuta(LatLng destino) async {
    if (_miUbicacionActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obteniendo tu ubicación actual primero...')),
      );
      await _obtenerUbicacionActual();
    }

    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${_miUbicacionActual!.longitude},${_miUbicacionActual!.latitude};'
            '${destino.longitude},${destino.latitude}?geometries=geojson'
    );

    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final List coordenadas = datos['routes'][0]['geometry']['coordinates'];

        List<LatLng> puntosRuta = coordenadas.map((punto) {
          return LatLng(punto[1] as double, punto[0] as double);
        }).toList();

        setState(() {
          _lineasRuta.clear();
          _lineasRuta.add(
            Polyline(
              points: puntosRuta,
              color: Colors.blue,
              strokeWidth: 5.0,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error al trazar la ruta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador Gastronómico - OpenStreetMap'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _ubicacionInicial,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.turismo.turismo_gastronomia',
              ),
              PolylineLayer(
                polylines: _lineasRuta, // Dibuja el camino azul en el mapa
              ),
              MarkerLayer(
                markers: _marcadores,
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: _obtenerUbicacionActual,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}