import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import '../screens/trip_detail_screen.dart';

class TripTileWidget extends StatefulWidget {
  final TripModel trip;
  final bool isHistory; // true para mostrar fecha, false para mostrar destino frecuente

  const TripTileWidget({
    Key? key,
    required this.trip,
    this.isHistory =cd  false,
  }) : super(key: key);

  @override
  State<TripTileWidget> createState() => _TripTileWidgetState();
}

class _TripTileWidgetState extends State<TripTileWidget> {
  bool _isSelected = false;
  double _scale = 1.0;

  void _handleTap() {
    setState(() {
      _isSelected = !_isSelected;
      _scale = 0.96; // Micro-animación (Fase C)
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });

        // NUEVA NAVEGACIÓN: Nos movemos a la pantalla de detalle del viaje
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: widget.trip),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final didiOrange = const Color(0xFFFF7D00); // Color oficial DiDi

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isSelected ? const Color(0xFFFFF3E0) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.isHistory ? Icons.history : Icons.location_on,
                color: _isSelected ? didiOrange : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isHistory ? widget.trip.type : widget.trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _isSelected ? didiOrange : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isHistory
                          ? '${widget.trip.historyDate} • ${widget.trip.price}'
                          : 'Viaje rápido disponible • ${widget.trip.duration}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: _isSelected ? didiOrange : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}