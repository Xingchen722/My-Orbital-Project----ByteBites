class Canteen {
  final String id;
  final String name;
  final String location;
  final String image;
  final String description;
  final String operatingHours;

  Canteen({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.description,
    required this.operatingHours,
  });

  factory Canteen.fromJson(Map<String, dynamic> json) {
    return Canteen(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      operatingHours: json['operatingHours'] as String,
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
    };
  }
} 