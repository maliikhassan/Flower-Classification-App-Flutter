import 'dart:io';
import 'dart:developer' as devtools;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:seeds_classification/colors.dart';
import 'package:seeds_classification/detailScreen.dart';
import 'package:seeds_classification/documentation.dart';
import 'package:seeds_classification/historyScreen.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart' as special;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isDarkMode = false;
  File? filePath;
  String label = '';
  double confidence = 0.0;
  Interpreter? _interpreter;

  bool isLoading = false;



  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      var inputShape = _interpreter!.getInputTensor(0).shape;
      devtools.log("Model Input Shape: $inputShape"); // Print expected shape
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }


  Future<void> _runModel(File imageFile) async {
    if (_interpreter == null) return;

    const inputSize = 224;
    const numChannels = 3;
    final classLabels = await _loadLabels();

    try {
      final image = img.decodeImage(await imageFile.readAsBytes())!;
      final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

      final inputBuffer = Float32List(1 * inputSize * inputSize * numChannels);

      var pixelIndex = 0;
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          inputBuffer[pixelIndex++] = (pixel.r / 127.5) - 1.0;
          inputBuffer[pixelIndex++] = (pixel.g / 127.5) - 1.0;
          inputBuffer[pixelIndex++] = (pixel.b / 127.5) - 1.0;
        }
      }

      final input = inputBuffer.reshape([1, inputSize, inputSize, numChannels]);

      // Fixed output buffer initialization
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputBuffer = List<double>.filled(
        outputShape[0] * outputShape[1],
        0.0,
      ).reshape(outputShape);

      _interpreter!.run(input, outputBuffer);

      // Type-annotated processing
      final predictions = outputBuffer[0] as List<double>;
      final maxConfidence = predictions.reduce((double a, double b) => a > b ? a : b);
      final predictedIndex = predictions.indexOf(maxConfidence);

      setState(() {
        confidence = maxConfidence * 100;
        label = classLabels[predictedIndex];
      });

    } catch (e) {
      print('Error during inference: $e');
      setState(() {
        label = 'Prediction failed';
        confidence = 0.0;
      });
    }
  }
// Load labels from assets
  Future<List<String>> _loadLabels() async {
    try {
      return await rootBundle.loadString('assets/labels.txt')
          .then((text) => text.split('\n'));
    } catch (e) {
      return List.generate(7, (i) => 'Class $i'); // Fallback
    }
  }

  Future<void> _pickImage(ImageSource source) async {

    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
      isLoading = true;
    });

    await _runModel(imageMap);

    setState(() {
    isLoading = false; // Hide loading indicator
  });

    if (filePath != null) {
    Get.to(() => DetailsScreen(
      imagePath: filePath!,
      confidence: confidence,
      lebel: label,
      isDarkMode: isDarkMode,
    ));
  }
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Scaffold(
        backgroundColor: isDarkMode? Colors.black: null,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: isDarkMode? Color(0xFFEA3442) : Color(0xFFFEABD0),
          foregroundColor: isDarkMode? Colors.white : Colors.black,
          title: Text(
            "Flower Classifier" ,
            style: TextStyle(
              color: isDarkMode? Colors.white : null
            ),
          ),
          actions: [
            IconButton(onPressed: (){
              setState(() {
                Get.to(()=> DocumentationScreen(isDarkMode: isDarkMode));
              });
              
            }, icon: isDarkMode? HugeIcon(icon: HugeIcons.strokeRoundedFile01,color: Colors.white,) :HugeIcon(icon:HugeIcons.strokeRoundedFile01, color: Colors.black,)),
            IconButton(onPressed: (){
              setState(() {
                isDarkMode = !isDarkMode;
              });
              
            }, icon: isDarkMode? Icon(Icons.light_mode,color: Colors.white,) :Icon(Icons.dark_mode,color: Colors.black,)),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 12,horizontal: 30),
          child: Column(
            spacing: 20,
            children: [
              SizedBox(height: 5,),
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode? Colors.white: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode? Colors.white.withOpacity(0.3) :Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 5, // How much the shadow spreads
                      blurRadius: 5, // How blurry the shadow is
                       // X and Y offset of the shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: Image.asset(
                    isDarkMode? "assets/flowerdark.png" : "assets/flowerlight.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text("Pick From Gallery or Capture Image for Flowers Classification",
              textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode? Colors.white: null,
                  fontSize: 18
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){
                    _pickImage(ImageSource.camera);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode? Color(0xFFEA3442) :Color(0xFFFEABD0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 15,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedCamera02, color: isDarkMode? Colors.white :Colors.black,),
                        Text("Capture Image",
                        style: TextStyle(
                          color: isDarkMode? Colors.white :Colors.black,
                          fontWeight: FontWeight.bold,fontSize: 20),)
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){
                    _pickImage(ImageSource.gallery);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode? Color(0xFFEA3442) :Color(0xFFFEABD0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 15,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedImage01, color: isDarkMode? Colors.white :Colors.black,),
                        Text("From Gallery",
                        style: TextStyle(
                          color: isDarkMode? Colors.white :Colors.black,fontWeight: FontWeight.bold,fontSize: 20),)
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){
                    Get.to(()=>HistoryScreen(isDarkMode: isDarkMode,));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode? Color(0xFFEA3442) :Color(0xFFFEABD0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 15,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedWorkHistory, color: isDarkMode? Colors.white :Colors.black,),
                        Text("Show History",
                        style: TextStyle(
                          color: isDarkMode? Colors.white :Colors.black,fontWeight: FontWeight.bold,fontSize: 20),)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
      if (isLoading)
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                special.CupertinoActivityIndicator(
                  //valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  radius: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }
}
