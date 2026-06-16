import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/channel.dart';

class VideoPanel extends StatefulWidget {
  final Channel channel;
  final bool isFullScreen;
  final bool showInfoOverlay;
  final VoidCallback onTap;

  const VideoPanel({
    super.key,
    required this.channel,
    required this.isFullScreen,
    required this.showInfoOverlay,
    required this.onTap,
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
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: widget.channel.httpHeaders,
      );

      _controller = controller;

      await controller.initialize();
      await controller.setLooping(true);

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
    final VideoPlayerController? controller = _controller;

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
      onTap: widget.onTap,
      onDoubleTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.all(widget.isFullScreen ? 0 : 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 10),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildVideoContent(),
                ),

                if (!widget.isFullScreen)
                  Positioned(
                    bottom: 18,
                    right: 18,
                    child: _SmallHint(
                      text: 'OK / Toque para pantalla completa',
                    ),
                  ),

                if (widget.showInfoOverlay)
                  Positioned(
                    left: 24,
                    top: 24,
                    child: _ChannelInfoOverlay(
                      channel: widget.channel,
                      isFullScreen: widget.isFullScreen,
                    ),
                  ),

                if (_controller != null &&
                    _controller!.value.isInitialized &&
                    !_controller!.value.isPlaying)
                  Center(
                    child: InkWell(
                      onTap: _togglePlayPause,
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    final VideoPlayerController? controller = _controller;

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

class _ChannelInfoOverlay extends StatelessWidget {
  final Channel channel;
  final bool isFullScreen;

  const _ChannelInfoOverlay({
    required this.channel,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: isFullScreen ? 320 : 260,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isFullScreen ? 72 : 58,
            height: isFullScreen ? 48 : 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                channel.shortName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isFullScreen ? 21 : 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isFullScreen ? 28 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isFullScreen
                    ? '⬆️ ⬇️ cambiar canal  •  Atrás para volver'
                    : 'Presioná OK para pantalla completa',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isFullScreen ? 15 : 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallHint extends StatelessWidget {
  final String text;

  const _SmallHint({
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
        color: Colors.black.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
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
    return Container(
      color: const Color(0xFF101820),
      child: Center(
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
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'CANAL NO DISPONIBLE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}