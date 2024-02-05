import 'package:min_paarvai/server.dart';
import 'package:min_paarvai/translator.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToBraille extends StatefulWidget {
  final String text;

  const TextToBraille({super.key, required this.text});

  @override
  State<TextToBraille> createState() => _TextToBrailleState();
}

class _TextToBrailleState extends State<TextToBraille> {
  final TextEditingController _textController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  bool _isPlaying = false;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.text;
    flutterTts.setLanguage("ta-IN");
    flutterTts.setSpeechRate(0.5);
    setState(() {
      _isPlaying = false;
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _postCharacter() async {
    String text = _textController.text;
    if (_currentIndex >= 0 && _currentIndex < text.length) {
      String character = text[_currentIndex];
      doPost(character);
    }
  }

  void doPost(String character) async {
    String displayUrl = await getDisplayUrl();
    try {
      Response response = await Dio().post(displayUrl, data: character);
      debugPrint(response.data);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _decrementIndex() {
    setState(() {
      _currentIndex = (_currentIndex - 1).clamp(
          0,
          _textController.text.isNotEmpty
              ? _textController.text.length - 1
              : 0);
    });
    _postCharacter();
  }

  void _incrementIndex() {
    setState(() {
      _currentIndex = (_currentIndex + 1).clamp(
          0,
          _textController.text.isNotEmpty
              ? _textController.text.length - 1
              : 0);
    });
    _postCharacter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Display Braille"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              color: Colors.lightGreen.shade100,
              child: TextField(
                controller: _textController,
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
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
                  child: Center(
                      child: Text("$_currentIndex",
                          style: const TextStyle(fontSize: 20))),
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              "Current : ${_textController.text.isNotEmpty ? _textController.text[_currentIndex] : 'None'}",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () => _postCharacter(),
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Post'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () => doPost(" "),
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Clear'),
            ),
          ),
          !_isPlaying ? Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () async{
                await flutterTts.speak(_textController.text);
                setState(() {
                  _isPlaying = true;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Speak'),
            ),
          ) : Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () async {
                await flutterTts.stop();
                setState(() {
                  _isPlaying = false;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 5, 50),
              ),
              child: const Text('Stop'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Translator(text: _textController.text),
                  ),
                );
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
        ],
      ),
    );
  }
}
