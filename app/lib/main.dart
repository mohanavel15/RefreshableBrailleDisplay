import 'dart:io';

import 'package:app/braille.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:read_pdf_text/read_pdf_text.dart';

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

  void pickAPdf(BuildContext context) async {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    ).then((result) {
      if (result != null) {
        String path = result.files.single.path!;
        try {
          File(path).readAsString().then((text) {
          //ReadPdfText.getPDFtext(path).then((text) {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextTOBraille(text: text),
            ),
          );
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => pickAPdf(context),
          child: const Text("Pick A pdf"),
        ),
      ),
    );
  }
}
