class Channel {
  final int id;
  final String name;
  final String shortName;
  final String category;
  final String streamUrl;
  final bool isActive;

  const Channel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.streamUrl,
    this.isActive = true,
  });
}