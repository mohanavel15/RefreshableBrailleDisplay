import 'package:min_paarvai/braille.dart';
import 'package:min_paarvai/text_to_braille.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Translator extends StatefulWidget {
  final String text;

  const Translator({super.key, required this.text});

  @override
  State<Translator> createState() => _Translator();
}

class _Translator extends State<Translator> {
  final TextEditingController _inputTextController = TextEditingController();
  final TextEditingController _outputTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputTextController.text = widget.text;
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text To Braille"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              color: Colors.lightGreen.shade100,
              child: TextField(
                controller: _inputTextController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(5.0),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.lightGreen.shade100,
                ),
                textAlignVertical: TextAlignVertical.top,
                scrollPhysics: const BouncingScrollPhysics(),
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              color: Colors.lightGreen.shade100,
              child: TextField(
                controller: _outputTextController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(5.0),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.lightGreen.shade100,
                ),
                textAlignVertical: TextAlignVertical.top,
                scrollPhysics: const BouncingScrollPhysics(),
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () {
                _outputTextController.text = tamilToBraille(_inputTextController.text);
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Translate'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () => Clipboard.setData(
                  ClipboardData(text: _outputTextController.text)),
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Copy'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextToBraille(text: _inputTextController.text),
                    ),
                  );
                },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Display Braille'),
            ),
          ),
        ],
      ),
    );
  }
}
