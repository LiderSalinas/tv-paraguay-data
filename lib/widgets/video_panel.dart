import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/channel.dart';

class VideoPanel extends StatefulWidget {
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
  State<VideoPanel> createState() => _VideoPanelState();
}

class _VideoPanelState extends State<VideoPanel> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.channel.streamUrl != widget.channel.streamUrl ||
        oldWidget.channel.id != widget.channel.id) {
      _loadVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    final String url = widget.channel.streamUrl.trim();

    debugPrint('Cargando canal: ${widget.channel.name}');
    debugPrint('URL: $url');

    await _controller?.dispose();
    _controller = null;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (url.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;

      await controller.initialize();
      await controller.setLooping(true);

      // En Chrome/Web conviene mutear para evitar bloqueo de autoplay.
      // En Android/TV Box dejamos volumen normal.
      if (kIsWeb) {
        await controller.setVolume(0);
      } else {
        await controller.setVolume(1);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      try {
        await controller.play();
      } catch (playError) {
        debugPrint('Autoplay bloqueado o falló play(): $playError');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      debugPrint('Error cargando video: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _togglePlayPause() {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggleFullScreen,
      onDoubleTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.all(widget.isFullScreen ? 0 : 22),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(
                    widget.isFullScreen ? 0 : 10,
                  ),
                  border: widget.isFullScreen
                      ? null
                      : Border.all(
                          color: const Color(0xFF252525),
                          width: 2,
                        ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildVideoContent(),
                    ),

                    const Positioned(
                      top: 20,
                      right: 20,
                      child: _LiveBadge(),
                    ),

                    Positioned(
                      bottom: 18,
                      right: 20,
                      child: _HintBadge(
                        text: widget.isFullScreen
                            ? 'ESC / Atrás para volver'
                            : 'ENTER o toque para pantalla completa',
                      ),
                    ),

                    if (_controller != null &&
                        _controller!.value.isInitialized &&
                        !_controller!.value.isPlaying)
                      Center(
                        child: InkWell(
                          onTap: _togglePlayPause,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (!widget.isFullScreen) ...[
              const SizedBox(height: 16),
              _BottomInfoBar(channelName: widget.channel.name),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    final controller = _controller;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError || controller == null || !controller.value.isInitialized) {
      return _VideoErrorPlaceholder(channel: widget.channel);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _VideoErrorPlaceholder extends StatelessWidget {
  final Channel channel;

  const _VideoErrorPlaceholder({
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                channel.shortName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            channel.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'NO SE PUDO CARGAR EL VIDEO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _HintBadge extends StatelessWidget {
  final String text;

  const _HintBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _BottomInfoBar extends StatelessWidget {
  final String channelName;

  const _BottomInfoBar({
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Reproduciendo $channelName - TV Paraguay',
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
    );
  }
}