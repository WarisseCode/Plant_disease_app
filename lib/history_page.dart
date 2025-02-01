import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:io';
// import 'package:share/share.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _predictions;
  final Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _predictions = DatabaseHelper().fetchPredictions();
  }

  void _deleteSelectedItems() async {
    for (int id in _selectedItems) {
      await DatabaseHelper().deletePrediction(id);
    }
    setState(() {
      _predictions = DatabaseHelper().fetchPredictions();
      _selectedItems.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedItems.length} prediction(s) deleted successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /* void _sharePrediction(Map<String, dynamic> prediction) {
    final message = '''
Plant Name: ${prediction['plantName']}
Disease: ${prediction['disease']}
Advice: ${prediction['advice']}
Date: ${prediction['dateTime']}
''';

    // Share.share(message);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: [
          if (_selectedItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedItems,
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _predictions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No predictions found.'));
          }

          final predictions = snapshot.data!;
          return ListView.builder(
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              final isSelected = _selectedItems.contains(prediction['id']);

              return ListTile(
                leading: Image.file(
                  File(prediction['imagePath']),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(prediction['plantName']),
                subtitle: Text(
                  'Disease: ${prediction['disease']}\nAdvice: ${prediction['advice']}\nDate: ${prediction['dateTime']}',
                ),
    onLongPress: () {
                  setState(() {
                    if (isSelected) {
                      _selectedItems.remove(prediction['id']);
                    } else {
                      _selectedItems.add(prediction['id']);
                    }
                  });
                },
                onTap: () {
                  if (_selectedItems.isNotEmpty) {
                    setState(() {
                      if (isSelected) {
                        _selectedItems.remove(prediction['id']);
                      } else {
                        _selectedItems.add(prediction['id']);
                      }
                    });
                  } else {
                    Navigator.pushNamed(context, '/predict', arguments: prediction);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
