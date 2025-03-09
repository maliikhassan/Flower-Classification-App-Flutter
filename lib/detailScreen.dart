import 'dart:convert';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:seeds_classification/DB/sqfliteHelper.dart';

class DetailsScreen extends StatefulWidget {
  late File imagePath;
  late double confidence;
  late String lebel;
  late bool isDarkMode;
  
  DetailsScreen({
    super.key,
    required this.imagePath,
    required this.confidence,
    required this.lebel,
    required this.isDarkMode,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  File? path;
  double? confidence;
  String? label;
  final String pexelsApiKey = "OnWHbXqxdCdt6bhSMPMZVoExBT7oYJjhAlAAAebPKDX4heNAkloruDvj";

  String description = "Fetching description...";
  List<dynamic> imageUrls = [];

  @override
  void initState() {
    super.initState();
    path = widget.imagePath;
    confidence = widget.confidence;
    label = widget.lebel;
    fetchDescription();
    fetchImages();
  }

  Future<void> fetchDescription() async {
  try {
    final response = await http.get(Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(widget.lebel)}'));

    if (response.statusCode == 200) {
      setState(() {
        description = json.decode(response.body)['extract'] ?? "No description available.";
      });
    } else {
      setState(() {
        description = "No description found.";
      });
    }
  } catch (e) {
    setState(() {
      description = "Error fetching description.";
    });
  }
}


  Future<void> fetchImages() async {
    const String apiKey = "OnWHbXqxdCdt6bhSMPMZVoExBT7oYJjhAlAAAebPKDX4heNAkloruDvj";
    final url = Uri.parse("https://api.pexels.com/v1/search?query=$label flower&per_page=4");
    
    final response = await http.get(url, headers: {"Authorization": apiKey});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> urls = (data["photos"] as List).map((photo) => photo["src"]["medium"] as String).toList();
      setState(() => imageUrls = urls);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.white10 : null,
      appBar: AppBar(
        elevation: 1,
        //elevation: 1,
          backgroundColor: widget.isDarkMode? Color(0xFFEA3442) : Color(0xFFFEABD0),
          foregroundColor: widget.isDarkMode? Colors.white : Colors.black,
        title: Text(
          label!,
          style: TextStyle(color: widget.isDarkMode ? Colors.white : null),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          
          spacing: 8,
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                color: widget.isDarkMode? Color(0xFFEA3442): Color(0xFFFEABD0),
                elevation: 5,
                clipBehavior: Clip.hardEdge,
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          path!,
                          fit: BoxFit.cover,
                          height: 350,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Flower Name: ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  widget.isDarkMode
                                      ? Color(0xFFFEABD0)
                                      : Color(0xFFEA3442),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: Text(
                              label!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    widget.isDarkMode
                                        ? Colors.black87
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      //height: 300, // Fixed height for the chart
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              height: 20,
                              width:
                                  (confidence! / 100) *
                                  MediaQuery.of(context).size.width *
                                  1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue,
                                    Colors.cyan,
                                  ], // Fancy gradient effect
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              
                    Text(
                      "   Accuracy: ${confidence!.toStringAsFixed(0)}%",
              
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            imageUrls.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(child: CircularProgressIndicator()),
            Card(
              color: widget.isDarkMode? Colors.black: Colors.white70,
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                child: Column(
                  spacing: 5,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: widget.isDarkMode? Color(0xFFEA3442): Color(0xFFFEABD0),
                          ),
                          child: Text(
                            "${widget.lebel} Flower",
                            style: TextStyle(
                              fontSize: 20,
                              color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Spacer(),
                        IconButton(onPressed: (){}, icon: HugeIcon(icon: HugeIcons.strokeRoundedShare05, color: widget.isDarkMode?Colors.white:Colors.black))
                      ],
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final seed = Seed(
              imagePath: widget.imagePath.path,
              seedType: widget.lebel,
              confidence: widget.confidence,
              dateTime: DateTime.now().toString(),
            );
            await DatabaseHelper().insertSeed(seed);
            
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30,vertical: 12),
                    backgroundColor:
                        widget.isDarkMode ? Colors.black : Colors.white,
                    foregroundColor:
                        widget.isDarkMode
                            ? Colors.white
                            : Colors.black, // Text color
                    elevation: 4, // Slight shadow for a fancy look
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    children: [
                      HugeIcon(icon: HugeIcons.strokeRoundedBookmark01, color: widget.isDarkMode? Colors.white : Colors.black),
                      Text(
                        "Save",
                        style: TextStyle(
                          color:  widget.isDarkMode? Colors.white : Colors.black,
                          fontSize: 20
                        ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 5,)
              ],
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
