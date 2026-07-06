import 'package:flutter/material.dart';
import '../../data/models/track_model.dart';

class TrackTileWidget extends StatefulWidget {
  final TrackModel track;

  const TrackTileWidget({Key? key, required this.track}) : super(key: key);

  @override
  State<TrackTileWidget> createState() => _TrackTileWidgetState();
}

class _TrackTileWidgetState extends State<TrackTileWidget> {
  bool _isPlaying = false;
  double _scale = 1.0;

  void _handleTap() {
    setState(() {
      _isPlaying = !_isPlaying;
      _scale = 0.95; // Efecto de hundido
    });

    // Regresa a su tamaño original después de un instante (micro-animación)
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = const Color(0xFFFF5500);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  widget.track.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[900],
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // SI ESTÁ REPRODUCIENDO CAMBIA A NARANJA (MEJORA UX)
                        color: _isPlaying ? orangeColor : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                            Icons.play_arrow,
                            size: 12,
                            color: _isPlaying ? orangeColor : Colors.grey
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.track.plays} • ${widget.track.duration}',
                          style: TextStyle(
                              color: _isPlaying ? orangeColor.withOpacity(0.8) : Colors.grey,
                              fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.more_vert,
                    color: _isPlaying ? orangeColor : Colors.white54
                ),
                onPressed: _handleTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}