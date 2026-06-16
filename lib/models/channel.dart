class Channel {
  final int id;
  final String name;
  final String shortName;
  final String category;
  final String playerType;
  final String streamUrl;
  final String webUrl;
  final String logoUrl;
  final Map<String, String> httpHeaders;
  final bool isActive;

  const Channel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.playerType,
    required this.streamUrl,
    required this.webUrl,
    required this.logoUrl,
    required this.httpHeaders,
    required this.isActive,
  });

  bool get isHls => playerType.toLowerCase() == 'hls';

  bool get isWebView => playerType.toLowerCase() == 'webview';

  String get playbackUrl {
    if (isWebView) return webUrl;
    return streamUrl;
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawHeaders = json['httpHeaders'];

    return Channel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      shortName: json['shortName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      playerType: json['playerType']?.toString() ??
          _detectPlayerType(
            json['streamUrl']?.toString() ?? '',
            json['webUrl']?.toString() ?? '',
          ),
      streamUrl: json['streamUrl']?.toString() ?? '',
      webUrl: json['webUrl']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      httpHeaders: _parseHeaders(rawHeaders),
      isActive: json['isActive'] is bool ? json['isActive'] : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'category': category,
      'playerType': playerType,
      'streamUrl': streamUrl,
      'webUrl': webUrl,
      'logoUrl': logoUrl,
      'httpHeaders': httpHeaders,
      'isActive': isActive,
    };
  }

  static String _detectPlayerType(String streamUrl, String webUrl) {
    if (webUrl.isNotEmpty && streamUrl.isEmpty) {
      return 'webview';
    }

    return 'hls';
  }

  static Map<String, String> _parseHeaders(dynamic rawHeaders) {
    if (rawHeaders == null) return {};

    if (rawHeaders is Map) {
      return rawHeaders.map(
        (key, value) => MapEntry(
          key.toString(),
          value.toString(),
        ),
      );
    }

    return {};
  }
}