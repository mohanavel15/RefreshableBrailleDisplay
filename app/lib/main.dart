import 'dart:io';

import 'package:app/server.dart';
import 'package:app/text_to_braille.dart';
import 'package:app/translator.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade300),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  void readDocx(BuildContext context) async {
    List<String> exts = ['docx'];
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: exts,
    );

    if (result != null) {
      String path = result.files.single.path!;
      try {
        final file = File(path);
        final bytes = await file.readAsBytes();
        final text = docxToText(bytes);

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Translator(text: text),
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void readImage(BuildContext context) async {
    List<String> exts = ['jpg', 'jpeg', 'png'];
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: exts,
    );

    if (result != null) {
      String path = result.files.single.path!;
      try {
        String text = await FlutterTesseractOcr.extractText(path, language: 'tam+eng');

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Translator(text: text),
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.build, color: Colors.grey),
            onPressed: () async {
              final formKey = GlobalKey<FormState>();
              final controller = TextEditingController();
              getServerUrl().then((value) => controller.text = value);

              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter URL',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              saveToFile(controller.text).then((value) {
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => readDocx(context),
                child: const Text('Pick a Document'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => readImage(context),
                child: const Text('Pick a Image'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TextToBraille(text: ""),
                    ),
                  );
                },
                child: const Text('Display Braille'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Translator(text: ""),
                    ),
                  );
                },
                child: const Text('Translate a Text'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
