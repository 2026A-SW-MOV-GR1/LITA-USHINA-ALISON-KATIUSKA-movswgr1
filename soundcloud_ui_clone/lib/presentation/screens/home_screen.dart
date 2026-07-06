import 'package:flutter/material.dart';
import '../../data/models/track_model.dart';
import '../widgets/track_card_widget.dart';
import '../widgets/track_tile_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dividimos nuestros datos para simular contenidos diferentes en cada lista
    final horizontalTracks = mockTracks.take(8).toList();
    final verticalTracks1 = mockTracks.skip(2).take(8).toList();
    final verticalTracks2 = mockTracks.reversed.toList();

    return Scaffold(
      backgroundColor: Colors.black, // Color base de SoundCloud (Fase A)
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ==========================================
          // LISTA 1: Horizontal (Escuchado recientemente)
          // ==========================================
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Escuchado recientemente',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16.0),
              itemCount: horizontalTracks.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TrackCardWidget(track: horizontalTracks[index]);
              },
            ),
          ),

          // ==========================================
          // LISTA 2: Vertical (Tracks en Tendencia)
          // ==========================================
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tendencias globales',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Deja el control al ListView padre
            itemCount: verticalTracks1.length,
            itemBuilder: (context, index) {
              return TrackTileWidget(track: verticalTracks1[index]);
            },
          ),

          // ==========================================
          // LISTA 3: Vertical (Recomendados para ti)
          // ==========================================
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Artistas que te podrían gustar',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: verticalTracks2.length,
            itemBuilder: (context, index) {
              return TrackTileWidget(track: verticalTracks2[index]);
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}