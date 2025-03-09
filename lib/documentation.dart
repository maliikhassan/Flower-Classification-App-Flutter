import 'package:flutter/material.dart';

class DocumentationScreen extends StatelessWidget {
  final bool isDarkMode;

  DocumentationScreen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text("Documentation", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Color(0xFFEA3442): Color(0xFFFEABD0),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Cards Section
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  buildInfoCard("Flutter", "assets/flutter.png", "App built in Flutter"),
                  buildInfoCard("TensorFlow Lite", "assets/tflite.png", "Model trained in TensorFlow Lite"),
                  buildInfoCard("GetX", "assets/getx.png", "Navigation and State"),
                  buildInfoCard("Dataset", "assets/dataset.png", "Trained over 10,000+ images"),
                ],
              ),
              const SizedBox(height: 20),
              // About App Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "About App",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "This Flower Classification App uses a machine learning model to identify different types of flowers. The model is trained using TensorFlow Lite, enabling efficient on-device processing without requiring an internet connection. Users can capture a photo or upload an existing image for classification. The app provides the predicted flower type along with a confidence score indicating accuracy. Additionally, it fetches relevant descriptions and related images for a more informative experience. The model is trained on a diverse dataset containing over 10,000 images, covering 10 flower categories: Daisy, Lavender, Lily, Rose, Sunflower, Aster, Iris, Marigold, Orchid, and Poppy.",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, String imagePath, String description) {
    return Card(
      color: isDarkMode ? Color(0xFFEA3442) : Color(0xFFFEABD0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
