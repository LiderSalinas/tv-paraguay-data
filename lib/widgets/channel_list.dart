import 'package:flutter/material.dart';
import '../models/channel.dart';

class ChannelList extends StatefulWidget {
  final List<Channel> channels;
  final Channel selectedChannel;
  final ValueChanged<Channel> onChannelSelected;

  const ChannelList({
    super.key,
    required this.channels,
    required this.selectedChannel,
    required this.onChannelSelected,
  });

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final ScrollController _scrollController = ScrollController();

  static const double itemHeight = 56;

  @override
  void didUpdateWidget(covariant ChannelList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedChannel.id != widget.selectedChannel.id) {
      _scrollToSelectedChannel();
    }
  }

  void _scrollToSelectedChannel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final int selectedIndex = widget.channels.indexWhere(
        (channel) => channel.id == widget.selectedChannel.id,
      );

      if (selectedIndex == -1) return;

      final double targetOffset = (selectedIndex * itemHeight)
          .clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          )
          .toDouble();

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLogo(Channel channel) {
    if (channel.logoUrl.trim().isEmpty) {
      return _LogoFallback(text: channel.shortName);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        channel.logoUrl,
        width: 78,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _LogoFallback(text: channel.shortName);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return _LogoFallback(text: channel.shortName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 410,
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      color: const Color(0xFF050505),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TV PARAGUAY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.channels.length,
              itemBuilder: (context, index) {
                final Channel channel = widget.channels[index];
                final bool isSelected =
                    channel.id == widget.selectedChannel.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => widget.onChannelSelected(channel),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D6EFD)
                            : const Color(0xFF1B1B1B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF70A7FF)
                              : const Color(0xFF2C2C2C),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 42,
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 86,
                            height: 42,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: _buildLogo(channel),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              channel.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final String text;

  const _LogoFallback({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}