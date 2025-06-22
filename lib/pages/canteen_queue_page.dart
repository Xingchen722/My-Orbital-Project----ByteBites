import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/canteens.dart';

class CanteenQueuePage extends StatefulWidget {
  @override
  _CanteenQueuePageState createState() => _CanteenQueuePageState();
}

class _CanteenQueuePageState extends State<CanteenQueuePage> {
  Position? _userPosition;
  Map<String, double> _distances = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userPosition = position;
      _distances = {
        for (var canteen in canteens)
          canteen.name: Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            canteen.latitude,
            canteen.longitude,
          )
      };
    });
  }

  String estimateQueue(double distance, DateTime now) {
    if (now.hour >= 11 && now.hour <= 13) {
      if (distance < 100) return '排队可能性高';
      if (distance < 300) return '排队可能性中';
      return '排队可能性低';
    } else {
      if (distance < 100) return '排队可能性中';
      return '排队可能性低';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('食堂排队情况估算')),
      body: _userPosition == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: canteens.length,
              itemBuilder: (context, index) {
                final canteen = canteens[index];
                final distance = _distances[canteen.name] ?? 0;
                final queue = estimateQueue(distance, DateTime.now());
                return ListTile(
                  title: Text(canteen.name),
                  subtitle: Text('${canteen.location}\n距离：${distance.toStringAsFixed(1)} 米\n$queue'),
                  leading: Icon(Icons.restaurant),
                );
              },
            ),
    );
  }
} 