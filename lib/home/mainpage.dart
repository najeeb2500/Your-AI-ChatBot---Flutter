import 'package:flutter/material.dart';
import 'package:gemini/widgets/chat_widgets.dart';

class MainPage extends StatefulWidget {
  final String title;
  final String? apiKey;
  const MainPage({super.key,required this.apiKey,required this.title});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor:const Color.fromARGB(182, 184, 227, 230) ,
        title: Text(widget.title,),
        foregroundColor: Colors.black,
      ), 
      body: ChatWidgets(apiKey: widget.apiKey,),
    );
  }
}