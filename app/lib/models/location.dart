class TourLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final String description;
  final String audioUrl;
  final String imageUrl;

  TourLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
  });

  factory TourLocation.fromJson(Map<String, dynamic> json) {
    return TourLocation(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      description: json['description'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
