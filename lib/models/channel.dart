class Channel {
  final int id;
  final String name;
  final String shortName;
  final String category;
  final String streamUrl;
  final String logoUrl;
  final Map<String, String> httpHeaders;
  final bool isActive;

  const Channel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.streamUrl,
    this.logoUrl = '',
    this.httpHeaders = const {},
    this.isActive = true,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawHeaders = json['httpHeaders'];

    Map<String, String> parsedHeaders = {};

    if (rawHeaders is Map) {
      parsedHeaders = rawHeaders.map(
        (key, value) => MapEntry(
          key.toString(),
          value.toString(),
        ),
      );
    }

    return Channel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'SIN NOMBRE',
      shortName: json['shortName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      streamUrl: json['streamUrl']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      httpHeaders: parsedHeaders,
      isActive: json['isActive'] == true,
    );
  }
}