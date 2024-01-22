from flask import Flask, request, jsonify
from flask_mqtt import Mqtt

import uuid
import os

import cv2
import pytesseract
import fitz
import re

pytesseract.pytesseract.tesseract_cmd = 'Tesseract-ocr\\tesseract.exe'


brailleToEnglishDict = {
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
 '001011': '"', #closing quote
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
}
englishToBrailleDict = {value: key for key, value in brailleToEnglishDict.items()}

tamilToBrailleDict = {
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
}

brailleToTamilDict = {value: key for key, value in tamilToBrailleDict.items()}

try:
    os.mkdir("files")
    os.mkdir("files/pdf")
    os.mkdir("files/img")
except:
    pass

app = Flask(__name__)

app.config['MQTT_BROKER_URL'] = '127.0.0.1'
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_USERNAME'] = 'TheAPIServer'
# app.config['MQTT_PASSWORD'] = ''
app.config['MQTT_KEEPALIVE'] = 5
app.config['MQTT_TLS_ENABLED'] = False

app.config['MQTT_TOPIC'] = 'braille'

mqtt_client = Mqtt(app)


@mqtt_client.on_connect()
def handle_connect(client, userdata, flags, rc):
    if rc == 0:
        print('Connected successfully')
        mqtt_client.subscribe(app.config['MQTT_TOPIC'])
    else:
        print('Bad connection. Code:', rc)

@mqtt_client.on_message()
def handle_mqtt_message(client, userdata, message):
    data = dict(
        topic=message.topic,
        payload=message.payload.decode()
    )
    print('Received message on topic: {topic} with payload: {payload}'.format(**data))


@app.route('/pdf', methods=['POST'])
def upload_pdf():
    file = request.files['file']
    path = './files/pdf/{}.pdf'.format(uuid.uuid4())
    file.save(path)
    
    pdf_document = fitz.open(path)
    num_pages = pdf_document.page_count
    text=''
    for page_num in range(num_pages):
        page = pdf_document.load_page(page_num)
        text += page.get_text()
        
    os.remove(path)
    
    return text


@app.route('/img', methods=['POST'])
def upload_image():
    file = request.files['file']
    path = './files/img/{}.jpg'.format(uuid.uuid4())
    file.save(path)
    
    img = cv2.imread(path, cv2.IMREAD_COLOR)
    text = pytesseract.image_to_string(img, lang='tam')
    
    os.remove(path)
    
    return text


@app.route('/display', methods=['POST'])
def display_data():
    data = request.data
    print(data)
    character = data[0]
    if re.match("^[A-Za-z0-9]$", character):
        to_translate = englishToBrailleDict[character.lower()]
        if to_translate.endswith('_'):
            to_translate = to_translate[:-1]
        hex_val = hex(int(to_translate, 2))[2:]
        mqtt_client.publish(app.config['MQTT_TOPIC'], hex_val)
    else:
        to_translate = tamilToBrailleDict[character]
        if to_translate.endswith('_'):
            to_translate = to_translate[:-1]
        hex_val = hex(int(to_translate, 2))[2:]
        mqtt_client.publish(app.config['MQTT_TOPIC'], hex_val)

    return 'Data printed successfully'
# 
@app.route('/ping_mqtt', methods=['GET'])
def ping_mqtt():
    mqtt_client.publish(app.config['MQTT_TOPIC'], 0xFF)
    return 'Pinded successfully'


if __name__ == '__main__':
    app.run(debug=True)
