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

  static const double itemHeight = 50;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
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
                  padding: const EdgeInsets.only(bottom: 5),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => widget.onChannelSelected(channel),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D6EFD)
                            : const Color(0xFF1B1B1B),
                        borderRadius: BorderRadius.circular(8),
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
                            width: 45,
                            child: Center(
                              child: Text(
                                '${channel.id}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 78,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                channel.shortName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
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