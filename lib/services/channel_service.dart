import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/channels_data.dart';
import '../models/channel.dart';

class ChannelService {
  static const String remoteChannelsUrl =
      'https://raw.githubusercontent.com/LiderSalinas/tv-paraguay-data/refs/heads/main/canales.json';

  Future<List<Channel>> getChannels() async {
    try {
      final uri = Uri.parse(
        '$remoteChannelsUrl?ts=${DateTime.now().millisecondsSinceEpoch}',
      );

      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        return paraguayChannelsFallback;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        return paraguayChannelsFallback;
      }

      final channels = decoded
          .map((item) => Channel.fromJson(item as Map<String, dynamic>))
          .where((channel) => channel.isActive)
          .toList();

      if (channels.isEmpty) {
        return paraguayChannelsFallback;
      }

      return channels;
    } catch (error) {
      return paraguayChannelsFallback;
    }
  }
}