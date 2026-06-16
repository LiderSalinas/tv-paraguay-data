import 'package:flutter/material.dart';

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

  List<Channel> _channels = [];
  Channel? _selectedChannel;

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final channels = await _channelService.getChannels();

      setState(() {
        _channels = channels;
        _selectedChannel = channels.isNotEmpty ? channels.first : null;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo cargar la lista de canales.';
      });
    }
  }

  void _selectChannel(Channel channel) {
    setState(() {
      _selectedChannel = channel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('TV Paraguay'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Actualizar canales',
            onPressed: _loadChannels,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildError();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Row(
            children: [
              SizedBox(
                width: 330,
                child: ChannelList(
                  channels: _channels,
                  selectedChannel: _selectedChannel,
                  onChannelSelected: _selectChannel,
                ),
              ),
              Expanded(
                child: VideoPanel(
                  channel: _selectedChannel,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              flex: 5,
              child: VideoPanel(
                channel: _selectedChannel,
              ),
            ),
            Expanded(
              flex: 4,
              child: ChannelList(
                channels: _channels,
                selectedChannel: _selectedChannel,
                onChannelSelected: _selectChannel,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.redAccent,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadChannels,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}