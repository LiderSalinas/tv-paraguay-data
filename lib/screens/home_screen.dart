import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/channel.dart';
import '../services/channel_service.dart';
import '../widgets/channel_list.dart';
import '../widgets/video_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChannelService _channelService = ChannelService();
  late final FocusNode _focusNode;

  List<Channel> channels = [];
  int selectedIndex = 0;

  bool isFullScreen = false;
  bool isLoading = true;
  bool showFullScreenInfo = false;

  Timer? _infoTimer;

  Channel get selectedChannel => channels[selectedIndex];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadChannels();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _infoTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    final loadedChannels = await _channelService.getChannels();

    if (!mounted) return;

    setState(() {
      channels = loadedChannels;
      selectedIndex = 0;
      isLoading = false;
    });

    _focusNode.requestFocus();
  }

  void _showInfoTemporarily() {
    _infoTimer?.cancel();

    setState(() {
      showFullScreenInfo = true;
    });

    _infoTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        showFullScreenInfo = false;
      });
    });
  }

  void _toggleInfoOverlay() {
    _infoTimer?.cancel();

    setState(() {
      showFullScreenInfo = !showFullScreenInfo;
    });

    if (showFullScreenInfo) {
      _infoTimer = Timer(const Duration(seconds: 4), () {
        if (!mounted) return;

        setState(() {
          showFullScreenInfo = false;
        });
      });
    }

    _focusNode.requestFocus();
  }

  void selectChannel(Channel channel) {
    final int index = channels.indexWhere(
      (item) => item.id == channel.id,
    );

    if (index == -1) return;

    setState(() {
      selectedIndex = index;
    });

    if (isFullScreen) {
      _showInfoTemporarily();
    }

    _focusNode.requestFocus();
  }

  void moveSelection(int direction) {
    if (channels.isEmpty) return;

    final int totalChannels = channels.length;
    int nextIndex = selectedIndex + direction;

    if (nextIndex < 0) {
      nextIndex = totalChannels - 1;
    }

    if (nextIndex >= totalChannels) {
      nextIndex = 0;
    }

    setState(() {
      selectedIndex = nextIndex;
    });

    if (isFullScreen) {
      _showInfoTemporarily();
    }

    _focusNode.requestFocus();
  }

  void enterFullScreen() {
    if (isFullScreen) return;

    setState(() {
      isFullScreen = true;
    });

    _showInfoTemporarily();
    _focusNode.requestFocus();
  }

  void exitFullScreen() {
    if (!isFullScreen) return;

    _infoTimer?.cancel();

    setState(() {
      isFullScreen = false;
      showFullScreenInfo = false;
    });

    _focusNode.requestFocus();
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      moveSelection(1);
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      moveSelection(-1);
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (isFullScreen) {
        _toggleInfoOverlay();
      } else {
        enterFullScreen();
      }
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.backspace ||
        event.logicalKey == LogicalKeyboardKey.goBack) {
      exitFullScreen();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (channels.isEmpty) {
      return const Center(
        child: Text(
          'No hay canales disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
      );
    }

    if (isFullScreen) {
      return VideoPanel(
        channel: selectedChannel,
        isFullScreen: true,
        showInfoOverlay: showFullScreenInfo,
        onTap: _toggleInfoOverlay,
      );
    }

    return Row(
      children: [
        ChannelList(
          channels: channels,
          selectedChannel: selectedChannel,
          onChannelSelected: selectChannel,
        ),
        Expanded(
          child: VideoPanel(
            channel: selectedChannel,
            isFullScreen: false,
            showInfoOverlay: true,
            onTap: enterFullScreen,
          ),
        ),
      ],
    );
  }
}