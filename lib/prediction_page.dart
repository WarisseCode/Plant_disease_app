import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'plant_data.dart';  // Importer les données des plantes

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String? _result;
  String? _accuracy;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/models/trained_plant_disease_model.tflite");
      print("Modèle chargé avec succès");
    } catch (e) {
      print("Erreur lors du chargement du modèle: $e");
      _showDialog("Impossible de charger le modèle. Vérifiez son chemin et son format.");
    }
  }

  bool _isModelLoaded() {
    if (_interpreter == null) {
      _showDialog("Le modèle n'est pas chargé. Veuillez réessayer.");
      return false;
    }
    return true;
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(String imagePath) async {
    File imageFile = File(imagePath);
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());
  
    if (image == null) {
      throw Exception("Impossible de charger l'image");
    }

    img.Image resizedImage = img.copyResize(image, width: 128, height: 128);

    List<List<List<List<double>>>> inputBuffer = List.generate(1, (batch) => 
        List.generate(128, (y) => 
          List.generate(128, (x) => 
            List.generate(3, (c) {
              int pixel = resizedImage.getPixel(x, y);
              if (c == 0) return (img.getRed(pixel) - 127.5) / 127.5;
              if (c == 1) return (img.getGreen(pixel) - 127.5) / 127.5;
              return (img.getBlue(pixel) - 127.5) / 127.5;
            })
          )
        )
      );
  
    return inputBuffer;
  }

  Future<void> _predict(String imagePath) async {
  if (!_isModelLoaded()) return;

  setState(() {
    _isProcessing = true;
    _result = null;
    _accuracy = null;
  });

  try {
    var input = await _preprocessImage(imagePath);
    List<List<double>> output = List.generate(1, (index) => List.filled(39, 0));

    _interpreter!.run(input, output);

    int bestIndex = 0;
    double bestConfidence = 0.0;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > bestConfidence) {
        bestConfidence = output[0][i];
        bestIndex = i;
      }
    }

    // Utiliser l'indice pour obtenir le nom de la plante à partir de plantNames
    String plantName = classNames[bestIndex];

    setState(() {
      _result = "Résultat: $plantName";  // Afficher le nom de la plante
      _accuracy = "Précision: ${(bestConfidence * 100).toStringAsFixed(2)}%";
      _isProcessing = false;
    });
  } catch (e) {
    setState(() {
      _isProcessing = false;
    });
    _showDialog("Erreur lors de la prédiction: $e");
  }
}


  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Attention"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prédiction de maladies des plantes")),
      body: Center(
        child: _isProcessing
            ? const SpinKitFadingCircle(color: Colors.green, size: 50.0)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_result ?? "Chargez une image pour prédire", textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (_accuracy != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_accuracy!, style: const TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        await _predict(pickedFile.path);
                      } else {
                        _showDialog("Aucune image sélectionnée.");
                      }
                    },
                    child: const Text("Charger une image"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        await _predict(pickedFile.path);
                      } else {
                        _showDialog("Aucune image capturée.");
                      }
                    },
                    child: const Text("Prendre une photo"),
                  ),
                ],
              ),
      ),
    );
  }
}
