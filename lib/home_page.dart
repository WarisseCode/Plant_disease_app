// home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease App'),
      ),
      drawer: Drawer(
        width: 200,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            ListTile(
              title: Text('Prediction'),
              onTap: () => Navigator.pushNamed(context, '/predict'),
            ),
            ListTile(
              title: Text('History'),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),

          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/home_page.jpg',
            errorBuilder: (context, error, stackTrace) {
              return const Text('Image introuvable.');
              },
              height: 200),
            SizedBox(height: 20),
            Text(
              'Welcome to the Plant Disease Detection App!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'This app helps you detect plant diseases quickly and efficiently. Use the menu to navigate through the features.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
