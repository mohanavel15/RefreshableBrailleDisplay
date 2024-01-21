import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const server = '192.168.223.142';
const port = 1883;
const clientId = 'flutter-publisher';

const Map<String, String> brailleToEnglishDict = {
  '100000': 'a',
  '110000': 'b',
  '100100': 'c',
  '100110': 'd',
  '100010': 'e',
  '110100': 'f',
  '110110': 'g',
  '110010': 'h',
  '010100': 'i',
  '010110': 'j',
  '101000': 'k',
  '111000': 'l',
  '101100': 'm',
  '101110': 'n',
  '101010': 'o',
  '111100': 'p',
  '111110': 'q',
  '111010': 'r',
  '011100': 's',
  '011110': 't',
  '101001': 'u',
  '111001': 'v',
  '010111': 'w',
  '101101': 'x',
  '101111': 'y',
  '101011': 'z',
  '000001': "capflag",
  '001111': '#',
  '000000': ' ',
  '010011': '.',
  '010000': ',',
  '011001': '?',
  '011000': ';',
  '011010': '!',
  '001011': '"', //closing quote
  '100000_': '1',
  '110000_': '2',
  '100100_': '3',
  '100110_': '4',
  '100010_': '5',
  '110100_': '6',
  '110110_': '7',
  '110010_': '8',
  '101100_': '9',
  '010110_': '0',
};

Map<String, String> englishToBrailleDict = brailleToEnglishDict.map((key, value) => MapEntry(value, key));

const Map<String, String> tamilToBrailleDict = {
  ' ': '000000',
  '.': '010011',
  ',': '010000',
  '?': '011001',
  ';': '011000',
  '!': '011010',
  '"': '001011',
  'ஜ': '010110',
  'ஸ': '011100',
  'ஷ': '111101',
  'ஹ': '110010',
  'க்ஷ': '111110',
  'அ': '100000',
  'ஆ': '001110',
  'இ': '010100',
  'ஈ': '001010',
  'உ': '101001',
  'ஊ': '110011',
  'எ': '010001',
  'ஏ': '100010',
  'ஐ': '001100',
  'ஒ': '101101',
  'ஓ': '101010',
  'ஔ': '010101',
  'க': '101000',
  'ங': '001101',
  'ச': '100100',
  'ஞ': '010010',
  'ட': '011111',
  'ண': '001111',
  'த': '011110',
  'ந': '101110',
  'ப': '111100',
  'ம': '101100',
  'ய': '101111',
  'ர': '111010',
  'ல': '111000',
  'வ': '111001',
  'ழ': '111011',
  'ள': '000111',
  'ற': '110111',
  'ன': '000011',
  '்': '000100_',
  'ா': '001110_',
  'ி': '010100_',
  'ீ': '001010_',
  'ு': '101001_',
  'ூ': '110011_',
  'ெ': '010001_',
  'ே': '100010_',
  'ை': '001100_',
  'ொ': '101101_',
  'ோ': '101010_',
  'ௌ': '010101_'
};

int binaryToDecimal(String binary) {
  if (binary.endsWith('_')) {
    binary = binary.substring(0, binary.length - 1);
  }
  int decimal = 0;
  for (int i = 0; i < binary.length; i++) {
    if (binary[i] == '1') {
      decimal += pow(2, binary.length - 1 - i).toInt();
    }
  }
  return decimal;
}

class TextTOBraille extends StatefulWidget {
  const TextTOBraille({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<TextTOBraille> createState() => _TextTOBrailleState();
}

class _TextTOBrailleState extends State<TextTOBraille> {
  late MqttServerClient client;
  int idx = 0;

  @override
  void initState() {
    super.initState();
    client = MqttServerClient.withPort(server, clientId, port);
    client.logging(on: true);
  }

  void processText() async {
    debugPrint(widget.text);
    debugPrint(widget.text.length.toString());

    final builder = MqttClientPayloadBuilder();
    final RegExp english = RegExp(r'^[a-zA-Z0-9]+');

    List<String> characters = widget.text.split("");
    if (idx >= characters.length) {
      debugPrint('End of text');
      return;
    }

    String char = characters[idx];
    if (english.hasMatch(char)) {
      String? braille = englishToBrailleDict[char.toLowerCase()];
      if (braille != null) {
        int value = binaryToDecimal(braille);
        builder.addInt(value);
      }
    } else {
      String? braille = tamilToBrailleDict[char.toLowerCase()];
      if (braille != null) {
        int value = binaryToDecimal(braille);
        builder.addInt(value);
      }
    }

    try {
      await client.connect();
      const topic = 'text';

      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() {
      idx++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: processText,
          child: const Text("Process"),
        ),
      ),
    );
  }
}
