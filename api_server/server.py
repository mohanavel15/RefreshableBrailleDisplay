from flask import Flask, request, jsonify
from flask_mqtt import Mqtt

import uuid
import os

import cv2
import pytesseract
import fitz

pytesseract.pytesseract.tesseract_cmd = 'Tesseract-ocr\\tesseract.exe'

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

    return text


@app.route('/img', methods=['POST'])
def upload_image():
    file = request.files['file']
    path = './files/img/{}.jpg'.format(uuid.uuid4())
    file.save(path)
    
    img = cv2.imread(path, cv2.IMREAD_COLOR)
    text = pytesseract.image_to_string(img, lang='tam')
    
    return text


@app.route('/display', methods=['POST'])
def display_data():
    data = request.data
    print(data)


    return 'Data printed successfully'

@app.route('/ping_mqtt', methods=['GET'])
def ping_mqtt():
    mqtt_client.publish(app.config['MQTT_TOPIC'], 0xFF)
    return 'Pinded successfully'


if __name__ == '__main__':
    app.run(debug=True)
