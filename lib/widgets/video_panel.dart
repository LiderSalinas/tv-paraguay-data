import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/channel.dart';

class VideoPanel extends StatefulWidget {
  final Channel? channel;
  final bool isFullScreen;

  const VideoPanel({
    super.key,
    required this.channel,
    this.isFullScreen = false,
  });

  @override
  State<VideoPanel> createState() => _VideoPanelState();
}

class _VideoPanelState extends State<VideoPanel> {
  VideoPlayerController? _videoController;
  WebViewController? _webViewController;

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _webProgress = 0;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.channel?.id != widget.channel?.id ||
        oldWidget.isFullScreen != widget.isFullScreen) {
      _setupPlayer();
    }
  }

  Future<void> _setupPlayer() async {
    final channel = widget.channel;

    await _disposeVideoController();

    _webViewController = null;
    _webProgress = 0;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    if (channel == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (channel.isWebView) {
      _setupWebView(channel);
      return;
    }

    await _setupHls(channel);
  }

  Future<void> _setupHls(Channel channel) async {
    try {
      if (channel.streamUrl.trim().isEmpty) {
        throw Exception('Este canal no tiene streamUrl');
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(channel.streamUrl),
        httpHeaders: channel.httpHeaders,
      );

      _videoController = controller;

      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
        _errorMessage = '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No se pudo reproducir este canal.';
      });
    }
  }

  void _setupWebView(Channel channel) {
    if (kIsWeb) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Este canal usa WebView. Probalo en la APK Android del TV Box, no en Chrome.';
      });

      return;
    }

    try {
      if (channel.webUrl.trim().isEmpty) {
        throw Exception('Este canal no tiene webUrl');
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (!mounted) return;

              setState(() {
                _webProgress = progress;
              });
            },
            onPageStarted: (_) {
              if (!mounted) return;

              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = '';
              });
            },
            onPageFinished: (_) async {
              await _tryImproveWebPlayer();

              if (!mounted) return;

              setState(() {
                _isLoading = false;
                _hasError = false;
                _errorMessage = '';
              });
            },
            onWebResourceError: (error) {
              if (!mounted) return;

              if (error.isForMainFrame == true) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = 'No se pudo abrir el reproductor web.';
                });
              }
            },
          ),
        )
        ..loadRequest(
          Uri.parse(channel.webUrl),
          headers: channel.httpHeaders,
        );

      _webViewController = controller;

      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No se pudo preparar el reproductor web.';
      });
    }
  }

  Future<void> _tryImproveWebPlayer() async {
    final controller = _webViewController;

    if (controller == null) return;

    try {
      await controller.runJavaScript('''
        document.body.style.backgroundColor = 'black';
        document.documentElement.style.backgroundColor = 'black';

        const videos = document.querySelectorAll('video');

        videos.forEach(function(video) {
          video.setAttribute('playsinline', 'true');
          video.setAttribute('webkit-playsinline', 'true');
          video.autoplay = true;
          video.muted = false;

          try {
            video.play();
          } catch (e) {}
        });
      ''');
    } catch (_) {
      // Algunas páginas bloquean JavaScript externo.
      // No rompemos la app por eso.
    }
  }

  Future<void> _disposeVideoController() async {
    final controller = _videoController;

    if (controller != null) {
      try {
        await controller.pause();
        await controller.dispose();
      } catch (_) {}
    }

    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.channel;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildContent(channel),
          ),

          if (_isLoading) _buildLoadingOverlay(channel),

          if (_hasError) _buildErrorOverlay(channel),

          if (!_isLoading && !_hasError && channel != null)
            _buildChannelHeader(channel),
        ],
      ),
    );
  }

  Widget _buildContent(Channel? channel) {
    if (channel == null) {
      return const Center(
        child: Text(
          'Seleccioná un canal',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),
      );
    }

    if (channel.isWebView) {
      final controller = _webViewController;

      if (controller == null) {
        return const SizedBox.shrink();
      }

      return WebViewWidget(controller: controller);
    }

    final controller = _videoController;

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    if (widget.isFullScreen) {
      return Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(controller),
            _buildVideoControls(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls(VideoPlayerController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: Row(
        children: [
          IconButton(
            color: Colors.white,
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              });
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.redAccent,
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.replay),
            onPressed: () async {
              await controller.seekTo(Duration.zero);
              await controller.play();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(Channel? channel) {
    return Container(
      color: Colors.black.withValues(alpha: 0.70),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              channel == null ? 'Cargando...' : 'Cargando ${channel.name}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (channel?.isWebView == true) ...[
              const SizedBox(height: 8),
              Text(
                'WebView $_webProgress%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(Channel? channel) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              channel?.name ?? 'Canal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _setupPlayer,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelHeader(Channel channel) {
    return Positioned(
      left: 16,
      top: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.live_tv,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              channel.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: channel.isWebView ? Colors.blueGrey : Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                channel.isWebView ? 'WEB' : 'HLS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}