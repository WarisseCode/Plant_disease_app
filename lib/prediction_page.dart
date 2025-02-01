import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';


class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String? _result;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    // Charger le modèle principal
    String? res = await Tflite.loadModel(
      model: "assets/model/plant_disease_model.tflite",
      labels: "assets/model/labels.txt",
    );
    print("Modèle chargé: $res");
  }

  Future<bool> _isLeaf(String imagePath) async {
    // Si un modèle de validation de feuille est disponible
    var predictions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 1, // Classe la plus probable
      threshold: 0.5,
    );

    if (predictions != null && predictions.isNotEmpty) {
      int index = predictions[0]['index'];
      return index == 1; // Supposons que l'indice 1 correspond à "Feuille"
    }
    return false;
  }

  Future<void> _predict(String imagePath) async {
    setState(() {
      _isProcessing = true;
    });

    // Vérifier si c'est une feuille
    bool isLeaf = await _isLeaf(imagePath);
    if (!isLeaf) {
      _showDialog("L'image ne semble pas contenir une feuille.");
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Faire la prédiction principale
    var predictions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 5,
      threshold: 0.5,
    );

    if (predictions == null || predictions.isEmpty) {
      _showDialog("Aucune prédiction trouvée.");
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Vérifier le seuil de confiance
    double maxConfidence = predictions.map((e) => e['confidence']).reduce((a, b) => a > b ? a : b);
    if (maxConfidence < 0.6) {
      _showDialog("Confiance faible. L'image n'est probablement pas une feuille ou contient trop de bruit.");
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Récupérer la prédiction avec la plus haute confiance
    var bestPrediction = predictions[0];
    setState(() {
      _result = "Résultat: ${bestPrediction['label']} (Confiance: ${(bestPrediction['confidence'] * 100).toStringAsFixed(2)}%)";
      _isProcessing = false;
    });
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Attention"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prédiction de maladies des plantes"),
      ),
      body: Center(
        child: _isProcessing
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _result ?? "Chargez une image pour prédire",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Implémentation pour charger une image
                      String imagePath = "chemin/vers/votre/image.jpg"; // Remplacez avec le chemin de l'image
                      await _predict(imagePath);
                    },
                    child: Text("Charger une image"),
                  ),
                ],
              ),
      ),
    );
  }
}
