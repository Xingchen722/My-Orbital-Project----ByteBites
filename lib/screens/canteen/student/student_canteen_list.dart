import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/canteen.dart';
import 'package:flutter_application_1/screens/canteen/student/student_canteen_card.dart';

class StudentCanteenList extends StatefulWidget {
  const StudentCanteenList({super.key});

  @override
  State<StudentCanteenList> createState() => _StudentCanteenListState();
}

class _StudentCanteenListState extends State<StudentCanteenList> {
  final List<Canteen> _canteens = [
    Canteen(
      id: '1',
      name: 'The Summit',
      location: 'University Town',
      image: 'assets/summit.jpg',
      description: '现代化的餐饮中心，提供多样化的美食选择',
      operatingHours: '7:00 AM - 9:00 PM',
    ),
    Canteen(
      id: '2',
      name: 'Frontier',
      location: 'University Town',
      image: 'assets/frontier.jpg',
      description: '提供各种亚洲和西方美食',
      operatingHours: '7:00 AM - 8:00 PM',
    ),
    Canteen(
      id: '3',
      name: 'Techno Edge',
      location: 'Engineering',
      image: 'assets/techno.jpg',
      description: '靠近工程学院的便捷餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
    ),
    Canteen(
      id: '4',
      name: 'PGP',
      location: 'Prince George\'s Park',
      image: 'assets/pgp.jpg',
      description: '靠近PGP宿舍的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
    ),
    Canteen(
      id: '5',
      name: 'The Deck',
      location: 'Arts & Social Sciences',
      image: 'assets/deck.jpg',
      description: '靠近文学院的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
    ),
    Canteen(
      id: '6',
      name: 'The Terrace',
      location: 'Business School',
      image: 'assets/terrace.jpg',
      description: '靠近商学院的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
    ),
    Canteen(
      id: '7',
      name: 'Yusof Ishak House',
      location: 'Kent Ridge',
      image: 'assets/yih.jpg',
      description: '提供清真食品的餐厅',
      operatingHours: '7:00 AM - 8:00 PM',
    ),
    Canteen(
      id: '8',
      name: 'Fine Food',
      location: 'University Town',
      image: 'assets/images/fine_food.jpg',
      description: 'Premium dining experience with international cuisine',
      operatingHours: '11:00 AM - 10:00 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _canteens.length,
        itemBuilder: (context, index) {
          final canteen = _canteens[index];
          return StudentCanteenCard(canteen: canteen);
        },
      ),
    );
  }
} 