import 'package:flutter/material.dart';

class VendorCanteenPage extends StatelessWidget {
  const VendorCanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Vendor Dashboard', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text(
            'Manage your canteen and orders',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class VendorProfilePage extends StatelessWidget {
  const VendorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Vendor Profile', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Manage your vendor account', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class HomeScreenVendor extends StatefulWidget {
  const HomeScreenVendor({super.key});

  @override
  State<HomeScreenVendor> createState() => _HomeScreenVendorState();
}

class _HomeScreenVendorState extends State<HomeScreenVendor> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [VendorCanteenPage(), VendorProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ByteBites - Vendor'),
        backgroundColor: Colors.blue[700],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: const Color.fromARGB(255, 255, 254, 254),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
