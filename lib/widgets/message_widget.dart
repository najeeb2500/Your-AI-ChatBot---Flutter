import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageWidget extends StatelessWidget {
  final String? text;
  final Image? image;
  final bool isFromUser;
  const MessageWidget(
      {super.key,
      required this.image,
      required this.isFromUser,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isFromUser?MainAxisAlignment.end:MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          constraints:const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: isFromUser ?const Color.fromARGB(159, 33, 149, 243) :const Color.fromARGB(141, 223, 221, 221),
            borderRadius: BorderRadius.circular(18),
          ),
          padding:const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          margin:const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              if (text case final text?)
                MarkdownBody(
                  data: text,
                ),
              if (image case final image?) image,
            ],
          ),
        ))
      ],
    );
  }
}
