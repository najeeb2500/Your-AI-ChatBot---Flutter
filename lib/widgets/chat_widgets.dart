import 'package:flutter/material.dart';
import 'package:gemini/widgets/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class ChatWidgets extends StatefulWidget {
  final String? apiKey;
  const ChatWidgets({super.key, required this.apiKey});

  @override
  State<ChatWidgets> createState() => _ChatWidgetsState();
}

class _ChatWidgetsState extends State<ChatWidgets> {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final ScrollController _scrollController = ScrollController();

  bool _loading = false;

  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _typingController = TextEditingController();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      [];

  @override
  void initState() {
    _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest', apiKey: widget.apiKey ?? '');
    _chat = _model.startChat();
    super.initState();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(microseconds: 750),
          curve: Curves.easeInOutCirc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: widget.apiKey?.isNotEmpty ?? false
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: _generatedContent.length,
                    itemBuilder: (context, index) {
                      final content = _generatedContent[index];
                      return MessageWidget(
                        text: content.text,
                        image: content.image,
                        isFromUser: content.fromUser,
                      );
                    })
                : ListView(
                    children: const [
                      Text("no api found. please get it from gooogle ai stdio")
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: _sendMessage,
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    controller: _typingController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15.0),
                        hintText: "Enter something...",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ))),
                  ),
                ),
                const SizedBox.square(
                  dimension: 15,
                ),
                IconButton(
                  onPressed: () {
                    //to pick the image
                    _pickImage();
                  },
                  icon:const Icon(
                    Icons.image,
                    color: Colors.black,
                  ),
                ),
                if (!_loading)
                  IconButton(
                    onPressed: () {
                      //sent chat to gemini
      
                      _sendMessage(_typingController.text);
                    },
                    icon:const Icon(
                      Icons.send_outlined,
                      color: Colors.black,
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add((image: null, text: message, fromUser: true));

      final response = await _chat.sendMessage(Content.text(message));

      final text = response.text;

      _generatedContent.add((image: null, text: text, fromUser: false));

      if (text == null) {
        showError("No Response from Gemini");
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _typingController.clear();
      setState(() {
        _loading = false;
      });

      _textFieldFocus.requestFocus();
    }
  }

  Future<dynamic> showError(String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("something went wrong"),
            content: SingleChildScrollView(
              child: SelectableText(message),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _loading = true;
      });

      try {
        final bytes = await image.readAsBytes();
        final content = [
          Content.multi([
            TextPart(_typingController.text),
            DataPart('image.jpeg', bytes),
          ])
        ];

        _generatedContent.add((
          text: _typingController.text,
          image: Image.memory(bytes),
          fromUser: true,
        ));

        var respones = await _model.generateContent(content);

        var text = respones.text;

        _generatedContent.add((image: null, text: text, fromUser: false));

        if (text == null) {
          showError("No Response from Gemini");
        } else {
          setState(() {
            _loading = false;
            _scrollDown();
          });
        }
      } catch (e) {
        showError(e.toString());
        setState(() {
          _loading = false;
        });
      } finally {
        _typingController.clear();
        setState(() {
          _loading = false;
        });

        _textFieldFocus.requestFocus();
      }
    }
  }
}
