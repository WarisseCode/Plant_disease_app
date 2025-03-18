// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import de flutter_spinkit

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
            FutureBuilder(
              future: precacheImage(AssetImage('assets/images/home_page.jpg'), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.asset(
                    'assets/images/home_page.jpg',
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Image introuvable.');
                    },
                  );
                } else {
                  return SpinKitFadingCircle( // Affichage du loader
                    color: Colors.blueAccent,
                    size: 50.0,
                  );
                }
              },
            ),
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
