class Canteen {
  final String id;
  final String name;
  final String location;
  final String image;
  final String description;
  final String operatingHours;
  final double rating;
  final List<String> categories;
  final double latitude;
  final double longitude;
  final List<String> menu;

  Canteen({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.description,
    required this.operatingHours,
    this.rating = 0.0,
    this.categories = const [],
    required this.latitude,
    required this.longitude,
    required this.menu,
  });

  factory Canteen.fromJson(Map<String, dynamic> json) {
    return Canteen(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      operatingHours: json['operatingHours'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      menu: (json['menu'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'image': image,
      'description': description,
      'operatingHours': operatingHours,
      'rating': rating,
      'categories': categories,
      'latitude': latitude,
      'longitude': longitude,
      'menu': menu,
    };
  }
} 