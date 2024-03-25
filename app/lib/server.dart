import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getServerUrl() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  File ipFile = File('${appDocDir.path}/ip.txt');
  String serverUrl = "";
  try {
    serverUrl = await ipFile.readAsString();
  } catch  (_) {}
  return serverUrl.trim();
}

Future<void> saveToFile(String content) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  File ipFile = File('${appDocDir.path}/ip.txt');
  await ipFile.writeAsString(content);
}

Future<String> getDisplayUrl() async {
  var serverUrl = await getServerUrl();
  return "$serverUrl/display";
}

