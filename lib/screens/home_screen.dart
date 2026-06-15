import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/channels_data.dart';
import '../models/channel.dart';
import '../widgets/channel_list.dart';
import '../widgets/video_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool isFullScreen = false;

  late final FocusNode _focusNode;

  Channel get selectedChannel => paraguayChannels[selectedIndex];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void selectChannel(Channel channel) {
    final int index = paraguayChannels.indexWhere(
      (item) => item.id == channel.id,
    );

    if (index == -1) return;

    setState(() {
      selectedIndex = index;
    });

    _focusNode.requestFocus();
  }

  void moveSelection(int direction) {
    final int totalChannels = paraguayChannels.length;
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

    _focusNode.requestFocus();
  }

  void enterFullScreen() {
    if (isFullScreen) return;

    setState(() {
      isFullScreen = true;
    });

    _focusNode.requestFocus();
  }

  void exitFullScreen() {
    if (!isFullScreen) return;

    setState(() {
      isFullScreen = false;
    });

    _focusNode.requestFocus();
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
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
        exitFullScreen();
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
          child: isFullScreen
              ? VideoPanel(
                  channel: selectedChannel,
                  isFullScreen: true,
                  onToggleFullScreen: toggleFullScreen,
                )
              : Row(
                  children: [
                    ChannelList(
                      channels: paraguayChannels,
                      selectedChannel: selectedChannel,
                      onChannelSelected: selectChannel,
                    ),
                    Expanded(
                      child: VideoPanel(
                        channel: selectedChannel,
                        isFullScreen: false,
                        onToggleFullScreen: enterFullScreen,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}