class Canteen {
  final String name;
  final String location;
  final double latitude;
  final double longitude;

  Canteen({
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
  });
}

final List<Canteen> canteens = [
  Canteen(name: 'The Summit', location: 'University Town', latitude: 1.3056, longitude: 103.7737),
  Canteen(name: 'Frontier', location: 'University Town', latitude: 1.3062, longitude: 103.7726),
  Canteen(name: 'Techno Edge', location: 'Engineering', latitude: 1.2976, longitude: 103.7706),
  Canteen(name: 'PGP', location: "Prince George's Park", latitude: 1.2926, longitude: 103.7811),
  Canteen(name: 'The Deck', location: 'Arts & Social Sciences', latitude: 1.2966, longitude: 103.7732),
  Canteen(name: 'The Terrace', location: 'Business School', latitude: 1.2938, longitude: 103.7756),
  Canteen(name: 'Yusof Ishak House', location: 'Kent Ridge', latitude: 1.2991, longitude: 103.7802),
  Canteen(name: 'Fine Food', location: 'University Town', latitude: 1.3065, longitude: 103.7722),
]; 