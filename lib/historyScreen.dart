import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeds_classification/DB/sqfliteHelper.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final bool isDarkMode;
  
  HistoryScreen({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
          backgroundColor: isDarkMode? Color(0xFFEA3442) : Color(0xFFFEABD0),
          foregroundColor: isDarkMode? Colors.white : Colors.black,
        title: Text('History'),
        
        actions: [
          IconButton(onPressed: (){}, icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: isDarkMode ? Colors.white : Colors.black,)),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: FutureBuilder<List<Seed>>(
          future: DatabaseHelper().getSeeds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data found'));
            } else {
              final seeds = snapshot.data!;
              return ListView.builder(
                itemCount: seeds.length,
                itemBuilder: (context, index) {
                  final seed = seeds[index];
        
                  // Format date (only date, no time)
                  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(seed.dateTime));
        
                  // Round confidence to 1 decimal place
                  String confidence = double.parse(seed.confidence.toString()).toStringAsFixed(1);
        
                  return Card(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(seed.imagePath),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover, // Ensures the image covers the area
                        ),
                      ),
                      title: Text(seed.seedType, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                      subtitle: Text(
                        'Confidence: $confidence%\nDate: $formattedDate',
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }
}
