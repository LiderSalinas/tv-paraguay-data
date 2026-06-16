import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/channel.dart';

class ChannelService {
  static const String _localAssetPath = 'canales.json';

  static const String _remoteChannelsUrl =
      'https://raw.githubusercontent.com/LiderSalinas/tv-paraguay-data/main/canales.json';

  Future<List<Channel>> getChannels() async {
    try {
      final remoteChannels = await _loadRemoteChannels();

      if (remoteChannels.isNotEmpty) {
        return remoteChannels;
      }

      return await _loadLocalChannels();
    } catch (_) {
      return await _loadLocalChannels();
    }
  }

  Future<List<Channel>> _loadRemoteChannels() async {
    final response = await http
        .get(
          Uri.parse(_remoteChannelsUrl),
          headers: const {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo cargar la lista remota');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! List) {
      throw Exception('El JSON remoto no tiene formato de lista');
    }

    return decoded
        .map((item) => Channel.fromJson(Map<String, dynamic>.from(item)))
        .where((channel) => channel.isActive)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<List<Channel>> _loadLocalChannels() async {
    final jsonString = await rootBundle.loadString(_localAssetPath);
    final decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw Exception('El JSON local no tiene formato de lista');
    }

    return decoded
        .map((item) => Channel.fromJson(Map<String, dynamic>.from(item)))
        .where((channel) => channel.isActive)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }
}