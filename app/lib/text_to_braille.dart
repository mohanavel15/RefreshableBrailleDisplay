import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TextToBraille extends StatefulWidget {
  final String text;

  const TextToBraille({super.key, required this.text});

  @override
  State<TextToBraille> createState() => _TextToBrailleState();
}

class _TextToBrailleState extends State<TextToBraille> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.text;
    _inputController.text = "$_currentIndex";
  }

  @override
  void dispose() {
    _textController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _postCharacter() async {
    String text = _textController.text;
    if (_currentIndex >= 0 && _currentIndex < text.length) {
      String character = text[_currentIndex];
      String url = 'http://127.0.0.1:5000/display';
      try {
        Response response =
            await Dio().post(url, data: {'character': character});
        debugPrint(response.data);
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  void _decrementIndex() {
    setState(() {
      _currentIndex = (_currentIndex - 1).clamp(0, _textController.text.isNotEmpty ? _textController.text.length - 1 : 0);
      _inputController.text = "$_currentIndex";
    });
  }

  void _incrementIndex() {
    setState(() {
      _currentIndex = (_currentIndex + 1).clamp(0, _textController.text.isNotEmpty ? _textController.text.length - 1 : 0);
      _inputController.text = "$_currentIndex";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text To Braille"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: null,
            onChanged: (value) {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    onPressed: _decrementIndex,
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: const Size(100, 50),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    color: Colors.lightGreen.shade100,
                    child: TextField(
                      onChanged: (_) {
                        _postCharacter();
                      },
                      controller: _inputController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    onPressed: _incrementIndex,
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: const Size(100, 50),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
