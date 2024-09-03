import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini/home/mainpage.dart';

void main()async {
  await dotenv.load(fileName: ".env");
  runApp(GenerativeAISample(apiKey: dotenv.env['API_KEY'],));
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key,this.apiKey});

   final String? apiKey;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyChatBot',
      theme: ThemeData(            
        colorScheme: ColorScheme.fromSeed(
          // brightness: Brightness.dark,
          seedColor: Colors.white),
        useMaterial3: true,
      ),
      home:MainPage(apiKey:apiKey,title: "Gemini AI",),
    );
  }
}
