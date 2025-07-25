const Map<String, String> tamilToBrailleDict = {
  '=': '011011',
  '+': '011010_',
  '-': '010010_',
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
  '்': '000011_',
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
  'ௌ': '010101_',
  '1': '100000_',
  '2': '110000_',
  '3': '100100_',
  '4': '100110_',
  '5': '100010_',
  '6': '110100_',
  '7': '110110_',
  '8': '110010_',
  '9': '101100_',
  '0': '010110_',
};

String tamilToBraille(String tamil) {
  String outputString = '';
  for (var c in tamil.split('')) {
    if (!tamilToBrailleDict.containsKey(c.toLowerCase())) {
      continue;
    }

    String char = tamilToBrailleDict[c.toLowerCase()]!;
    if (char.endsWith("_")) {
      char = char.substring(0, char.length - 1);
    }
    int val = int.parse(char.split('').reversed.join(''), radix: 2);
    String toAdd = String.fromCharCode(10240 + val);
    outputString += toAdd;
  }
  return outputString;
}
