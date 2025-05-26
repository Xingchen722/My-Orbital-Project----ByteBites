import 'package:flutter/material.dart';

class CanteenPage extends StatelessWidget {
  const CanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Student Home', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('View and order from canteens', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Student Profile', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Manage your student account', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class HomeScreenStudent extends StatefulWidget {
  const HomeScreenStudent({super.key});

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [CanteenPage(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ByteBites - Student'),
        backgroundColor: Colors.green[700],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Canteens',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
