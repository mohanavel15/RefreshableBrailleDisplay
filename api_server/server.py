from flask import Flask, request, jsonify
from flask_mqtt import Mqtt

import uuid
import os

import cv2
import pytesseract
from docx import Document
import fitz
import re

import braille
# pytesseract.pytesseract.tesseract_cmd = 'Tesseract-ocr\\tesseract.exe'

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
    else:
        print('Bad connection. Code:', rc)

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

@app.route('/word', methods=['POST'])
def upload_word():
    file = request.files['file']
    path = './files/word/{}.docx'.format(uuid.uuid4())
    file.save(path)
    doc = Document(path)
    text=''
    Paras=doc.paragraphs
    for paragraph in Paras:
        text += paragraph.text
        
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
    data = request.data.decode('utf-8')
    character = data[0]
    if re.match("^[A-Za-z0-9]$", character):
        to_translate = braille.englishToBrailleDict.get(character.lower(), "000000")
        if to_translate.endswith('_'):
            to_translate = to_translate[:-1]
        
        val = int(to_translate, 2)
        mqtt_client.publish(app.config['MQTT_TOPIC'], val.to_bytes(1, 'little', signed=False))
    else:
        to_translate = braille.tamilToBrailleDict.get(character, "000000")
        if to_translate.endswith('_'):
            to_translate = to_translate[:-1]
        
        val = int(to_translate, 2)
        mqtt_client.publish(app.config['MQTT_TOPIC'], val.to_bytes(1, 'little', signed=False))

    return 'OK'

@app.route('/translate', methods=['POST'])
def translate_paragraph():
    data = request.data.decode('utf-8') #this is the paragraphs of text. 
    character = data[0]
    if re.match("^[A-Za-z]$", character):
        tosend = braille.para_to_braille(data,braille.englishToBrailleDict)
    else:
        tosend = braille.para_to_braille(data,braille.tamilToBrailleDict)
    
    return tosend
    

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)
