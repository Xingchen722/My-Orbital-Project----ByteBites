import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/canteen.dart';
import 'package:flutter_application_1/screens/canteen/student/student_canteen_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudentCanteenList extends StatefulWidget {
  const StudentCanteenList({super.key});

  @override
  State<StudentCanteenList> createState() => _StudentCanteenListState();
}

class _StudentCanteenListState extends State<StudentCanteenList> {
  final List<Canteen> _allCanteens = [
    Canteen(
      id: '1',
      name: 'The Summit',
      location: 'University Town',
      image: 'assets/summit.jpg',
      description: '现代化的餐饮中心，提供多样化的美食选择',
      operatingHours: '7:00 AM - 9:00 PM',
      latitude: 1.3056,
      longitude: 103.7737,
      menu: [
        'Chicken Rice', 'Laksa', 'Nasi Lemak', 'Char Kway Teow', 'Satay', 'Fishball Noodles', 'Vegetarian Rice', 'Western Food',
        'Mala Xiang Guo', 'Hainanese Chicken Rice', 'Korean Bibimbap', 'Japanese Ramen', 'Sushi', 'Kimchi Stew', 'Mapo Tofu', 'Beef Bulgogi'
      ],
    ),
    Canteen(
      id: '2',
      name: 'Frontier',
      location: 'University Town',
      image: 'assets/frontier.jpg',
      description: '提供各种亚洲和西方美食',
      operatingHours: '7:00 AM - 8:00 PM',
      latitude: 1.3062,
      longitude: 103.7726,
      menu: [
        'Chicken Rice', 'Bak Kut Teh', 'Roti Prata', 'Mee Goreng', 'Vegetarian Bee Hoon', 'Western Food', 'Japanese Curry', 'Korean Bibimbap',
        'Mala Tang', 'Sashimi', 'Tempura', 'Kimchi Fried Rice', 'Spicy Tofu Soup', 'Sichuan Boiled Fish', 'Udon', 'Takoyaki'
      ],
    ),
    Canteen(
      id: '3',
      name: 'Techno Edge',
      location: 'Engineering',
      image: 'assets/techno.jpg',
      description: '靠近工程学院的便捷餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
      latitude: 1.2976,
      longitude: 103.7706,
      menu: [
        'Chicken Rice', 'Laksa', 'Char Kway Teow', 'Economic Rice', 'Western Food', 'Japanese Ramen', 'Indian Curry', 'Fish Soup',
        'Mala Hotpot', 'Korean Fried Chicken', 'Sushi', 'Donburi', 'Kimchi Pancake', 'Sweet and Sour Pork', 'Teriyaki Chicken', 'Bibimbap'
      ],
    ),
    Canteen(
      id: '4',
      name: 'PGP',
      location: 'Prince George\'s Park',
      image: 'assets/pgp.jpg',
      description: '靠近PGP宿舍的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
      latitude: 1.2926,
      longitude: 103.7811,
      menu: [
        'Nasi Lemak', 'Roti Prata', 'Chicken Rice', 'Vegetarian Rice', 'Western Food', 'Tom Yum Soup', 'Thai Food', 'Indian Curry',
        'Mala Xiang Guo', 'Hainanese Chicken Rice', 'Korean BBQ', 'Japanese Curry', 'Sushi', 'Kimchi Stew', 'Mapo Tofu', 'Takoyaki'
      ],
    ),
    Canteen(
      id: '5',
      name: 'The Deck',
      location: 'Arts & Social Sciences',
      image: 'assets/deck.jpg',
      description: '靠近文学院的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
      latitude: 1.2966,
      longitude: 103.7732,
      menu: [
        'Chicken Rice', 'Laksa', 'Economic Rice', 'Western Food', 'Japanese Curry', 'Vegetarian Bee Hoon', 'Fishball Noodles', 'Korean Bibimbap',
        'Mala Tang', 'Sashimi', 'Tempura', 'Kimchi Fried Rice', 'Spicy Tofu Soup', 'Sichuan Boiled Fish', 'Udon', 'Teriyaki Chicken'
      ],
    ),
    Canteen(
      id: '6',
      name: 'The Terrace',
      location: 'Business School',
      image: 'assets/terrace.jpg',
      description: '靠近商学院的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
      latitude: 1.2938,
      longitude: 103.7756,
      menu: [
        'Chicken Rice', 'Bak Kut Teh', 'Laksa', 'Western Food', 'Vegetarian Rice', 'Fish Soup', 'Japanese Ramen', 'Tom Yum Soup',
        'Mala Hotpot', 'Korean Fried Chicken', 'Sushi', 'Donburi', 'Kimchi Pancake', 'Sweet and Sour Pork', 'Teriyaki Chicken', 'Bibimbap'
      ],
    ),
    Canteen(
      id: '7',
      name: 'Yusof Ishak House',
      location: 'Kent Ridge',
      image: 'assets/yih.jpg',
      description: '提供清真食品的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
      latitude: 1.2991,
      longitude: 103.7802,
      menu: [
        'Chicken Rice', 'Halal Food', 'Mee Goreng', 'Roti Prata', 'Western Food', 'Vegetarian Rice', 'Fishball Noodles', 'Satay',
        'Mala Xiang Guo', 'Hainanese Chicken Rice', 'Korean BBQ', 'Japanese Curry', 'Sushi', 'Kimchi Stew', 'Mapo Tofu', 'Takoyaki'
      ],
    ),
    Canteen(
      id: '8',
      name: 'Fine Food',
      location: 'University Town',
      image: 'assets/images/fine_food.jpg',
      description: 'Premium dining experience with international cuisine',
      operatingHours: '11:00 AM - 10:00 PM',
      latitude: 1.3065,
      longitude: 103.7722,
      menu: [
        'Steak', 'Pasta', 'Chicken Rice', 'Japanese Sushi', 'Korean BBQ', 'Western Food', 'Salad', 'Dessert',
        'Mala Tang', 'Sashimi', 'Tempura', 'Kimchi Fried Rice', 'Spicy Tofu Soup', 'Sichuan Boiled Fish', 'Udon', 'Teriyaki Chicken'
      ],
    ),
  ];

  List<Canteen> _filteredCanteens = [];
  Position? _userPosition;
  String? _locationError;
  String _searchText = '';
  String _sortType = 'distance'; // distance, rating, name
  Set<String> _favoriteCanteenIds = {};

  @override
  void initState() {
    super.initState();
    _filteredCanteens = List.from(_allCanteens);
    _loadFavorites();
    _getUserLocation();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorite_canteen_ids') ?? [];
    setState(() {
      _favoriteCanteenIds = favs.toSet();
    });
  }

  Future<void> _toggleFavorite(String canteenId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteCanteenIds.contains(canteenId)) {
        _favoriteCanteenIds.remove(canteenId);
      } else {
        _favoriteCanteenIds.add(canteenId);
      }
    });
    await prefs.setStringList('favorite_canteen_ids', _favoriteCanteenIds.toList());
    _applyFilterAndSort();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = '定位服务未开启';
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = '定位权限被拒绝';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = '定位权限被永久拒绝';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userPosition = position;
        _locationError = null;
      });
      _applyFilterAndSort();
    } catch (e) {
      setState(() {
        _locationError = '获取定位失败: $e';
      });
    }
  }

  void _applyFilterAndSort() async {
    List<Canteen> canteens = _allCanteens;
    // 菜名筛选（不输入时不过滤）
    if (_searchText.trim().isNotEmpty) {
      final query = _searchText.trim().toLowerCase();
      canteens = canteens.where((c) => c.menu.any((item) => item.toLowerCase().contains(query))).toList();
    }
    // 收藏筛选
    if (_sortType == 'favorite') {
      canteens = canteens.where((c) => _favoriteCanteenIds.contains(c.id)).toList();
    }
    // 动态获取评分
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<double>> canteenRatings = {};
    for (var c in canteens) {
      final key = 'canteen_reviews_${c.id}';
      List<String> reviewStrings = prefs.getStringList(key) ?? [];
      for (String reviewString in reviewStrings) {
        try {
          final reviewMap = jsonDecode(reviewString) as Map<String, dynamic>;
          final rating = (reviewMap['rating'] as num).toDouble();
          canteenRatings.putIfAbsent(c.id, () => []).add(rating);
        } catch (_) {}
      }
    }
    Map<String, double> avgRatings = {};
    for (var c in canteens) {
      final ratings = canteenRatings[c.id] ?? [];
      avgRatings[c.id] = ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;
    }
    // 排序
    if (_sortType == 'rating') {
      canteens.sort((a, b) => avgRatings[b.id]!.compareTo(avgRatings[a.id]!));
    } else if (_sortType == 'distance' && _userPosition != null) {
      canteens.sort((a, b) {
        double da = _distance(a.latitude, a.longitude, _userPosition!.latitude, _userPosition!.longitude);
        double db = _distance(b.latitude, b.longitude, _userPosition!.latitude, _userPosition!.longitude);
        return da.compareTo(db);
      });
    } else if (_sortType == 'name') {
      canteens.sort((a, b) => a.name.compareTo(b.name));
    }
    setState(() {
      _filteredCanteens = canteens;
    });
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371e3; // 地球半径，单位米
    final double phi1 = lat1 * pi / 180;
    final double phi2 = lat2 * pi / 180;
    final double deltaPhi = (lat2 - lat1) * pi / 180;
    final double deltaLambda = (lon2 - lon1) * pi / 180;
    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double d = R * c;
    return d;
  }

  String _estimateQueue(double distance, DateTime now, AppLocalizations l10n) {
    if (now.hour >= 11 && now.hour <= 13) {
      if (distance < 100) return l10n.queueCrowded;
      if (distance < 300) return l10n.queueMedium;
      return l10n.queueFew;
    } else {
      if (distance < 100) return l10n.queueMedium;
      return l10n.queueFew;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.queue),
                label: Text(l10n.queueEstimationButton),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(l10n.queueEstimationTitle),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: _userPosition == null
                              ? Center(child: CircularProgressIndicator())
                              : ListView(
                                  shrinkWrap: true,
                                  children: _allCanteens.map((canteen) {
                                    final distance = _userPosition == null
                                        ? 0.0
                                        : Geolocator.distanceBetween(
                                            _userPosition!.latitude,
                                            _userPosition!.longitude,
                                            canteen.latitude,
                                            canteen.longitude,
                                          );
                                    final queue = _estimateQueue(distance, DateTime.now(), l10n);
                                    return ListTile(
                                      title: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            canteen.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          queueIndicator(queue, l10n),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${canteen.location}\n${l10n.distance}：${distance.toStringAsFixed(1)} 米'),
                                          Text(queue),
                                        ],
                                      ),
                                      leading: Icon(Icons.restaurant),
                                    );
                                  }).toList(),
                                ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('关闭'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.searchByDish,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                      _applyFilterAndSort();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _sortType,
                  items: [
                    DropdownMenuItem(value: 'distance', child: Text(l10n.sortByDistance)),
                    DropdownMenuItem(value: 'rating', child: Text(l10n.sortByRating)),
                    DropdownMenuItem(value: 'name', child: Text(l10n.sortByName)),
                    DropdownMenuItem(value: 'favorite', child: Row(children: [Icon(Icons.favorite_border, color: Colors.red, size: 18), SizedBox(width: 4), Text(l10n.favoriteOnly)]))
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortType = value;
                      });
                      _applyFilterAndSort();
                    }
                  },
                ),
              ],
            ),
          ),
          if (_userPosition != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${l10n.currentPosition}：${_userPosition!.latitude.toStringAsFixed(5)}, ${_userPosition!.longitude.toStringAsFixed(5)}'),
            ),
          if (_locationError != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_locationError!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _filteredCanteens.isEmpty
                ? Center(child: Text(l10n.noCanteenFound))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCanteens.length,
                    itemBuilder: (context, index) {
                      final canteen = _filteredCanteens[index];
                      return Stack(
                        children: [
                          StudentCanteenCard(
                            canteen: canteen,
                            titleWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(canteen.name),
                                queueIndicator(
                                  _estimateQueue(
                                    _userPosition == null
                                        ? 0.0
                                        : Geolocator.distanceBetween(
                                            _userPosition!.latitude,
                                            _userPosition!.longitude,
                                            canteen.latitude,
                                            canteen.longitude,
                                          ),
                                    DateTime.now(),
                                    l10n,
                                  ),
                                  l10n,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                _favoriteCanteenIds.contains(canteen.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _favoriteCanteenIds.contains(canteen.id) ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _toggleFavorite(canteen.id),
                              tooltip: _favoriteCanteenIds.contains(canteen.id) ? l10n.cancel : l10n.add,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget queueIndicator(String queueType, AppLocalizations l10n) {
    Color color;
    if (queueType == l10n.queueCrowded) {
      color = Colors.red;
    } else if (queueType == l10n.queueMedium) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
} 