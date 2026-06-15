import 'package:flutter/material.dart';
import '../models/channel.dart';

class VideoPanel extends StatelessWidget {
  final Channel channel;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const VideoPanel({
    super.key,
    required this.channel,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleFullScreen,
      child: Container(
        color: const Color(0xFF000000),
        padding: EdgeInsets.all(isFullScreen ? 0 : 22),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(isFullScreen ? 0 : 10),
                  border: isFullScreen
                      ? null
                      : Border.all(
                          color: const Color(0xFF252525),
                          width: 2,
                        ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isFullScreen ? 180 : 150,
                            height: isFullScreen ? 120 : 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D6EFD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                channel.shortName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isFullScreen ? 42 : 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            channel.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isFullScreen ? 54 : 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isFullScreen
                                ? 'PANTALLA COMPLETA'
                                : 'CANAL SELECCIONADO',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 14,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'EN VIVO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 18,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isFullScreen
                              ? 'ESC / Atrás para volver'
                              : 'ENTER o toque para pantalla completa',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!isFullScreen) ...[
              const SizedBox(height: 16),
              Container(
                height: 58,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF07152A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Text(
                      '12:45',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Text(
                      '26.5°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Reproduciendo ${channel.name} - TV Paraguay',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}