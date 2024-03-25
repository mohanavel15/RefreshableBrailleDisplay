from flask import Flask, request
from flask_mqtt import Mqtt

import re

import braille

app = Flask(__name__)

app.config['MQTT_BROKER_URL'] = '127.0.0.1'
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_USERNAME'] = 'TheAPIServer'
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

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)
