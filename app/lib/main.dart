import 'package:app/server.dart';
import 'package:app/text_to_braille.dart';
import 'package:app/translator.dart';
import 'package:app/upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

  void pickFile(BuildContext context, String type) async {
    List<String> exts = [];
    if (type == 'docx') {
      exts = ['docx'];
    } else if (type == 'image') {
      exts = ['jpg', 'jpeg', 'png'];
    } else {
      debugPrint('unknown type');
    }

    FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: exts,
    )
        .then((result) {
      if (result != null) {
        String path = result.files.single.path!;
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileUpload(filePath: path, fileType: type),
            ),
          );
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
        title: const Text("Text to Braille"),
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
                onPressed: () => pickFile(context, "docx"),
                child: const Text('Pick a Document'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => pickFile(context, "image"),
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
                child: const Text('Send a Text'),
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
