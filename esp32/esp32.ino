#include <WiFi.h>
#include <PubSubClient.h>

const gpio_num_t PIN1 = GPIO_NUM_27;
const gpio_num_t PIN1R = GPIO_NUM_26;

const gpio_num_t PIN2 = GPIO_NUM_17;
const gpio_num_t PIN2R = GPIO_NUM_16;

const gpio_num_t PIN3 = GPIO_NUM_21;
const gpio_num_t PIN3R = GPIO_NUM_19;

const gpio_num_t PIN4 = GPIO_NUM_4;
const gpio_num_t PIN4R = GPIO_NUM_2;

const gpio_num_t PIN5 = GPIO_NUM_18;
const gpio_num_t PIN5R = GPIO_NUM_5;

const gpio_num_t PIN6 = GPIO_NUM_23;
const gpio_num_t PIN6R = GPIO_NUM_22;

const char* WLAN_SSID = "<username>";
const char* WLAN_PASS = "<password>";

const char* MQTT_SERVER = "192.168.x.x";
const int MQTT_PORT = 1883;
const char* MQTT_CLIENT = "esp_client";
const char* MQTT_TOPIC = "braille";

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  pinMode(PIN1, OUTPUT);
  pinMode(PIN1R, OUTPUT);

  pinMode(PIN2, OUTPUT);
  pinMode(PIN2R, OUTPUT);

  pinMode(PIN3, OUTPUT);
  pinMode(PIN3R, OUTPUT);

  pinMode(PIN4, OUTPUT);
  pinMode(PIN4R, OUTPUT);

  pinMode(PIN5, OUTPUT);
  pinMode(PIN5R, OUTPUT);

  pinMode(PIN6, OUTPUT);
  pinMode(PIN6R, OUTPUT);

  Serial.begin(115200);
  WiFi.begin(WLAN_SSID, WLAN_PASS);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }

  Serial.println("Connected to WiFi");

  client.setServer(MQTT_SERVER, MQTT_PORT);
  client.setCallback(callback);

  while (!client.connected()) {
    if (client.connect(MQTT_CLIENT)) {
      Serial.println("Connected to MQTT server");
      client.subscribe(MQTT_TOPIC);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

void loop() {
  client.loop();
}

void callback(char* topic, byte* payload, unsigned int length) {
  byte b = payload[0];
  display(b);
}

void display(byte b) {
  bool p1 = (b & 1) == 1;
  bool p2 = (b & 2) == 2;
  bool p3 = (b & 4) == 4;
  bool p4 = (b & 8) == 8;
  bool p5 = (b & 16) == 16;
  bool p6 = (b & 32) == 32;

  Serial.print(p6);
  Serial.print(p5);
  Serial.print(p4);
  Serial.print(p3);
  Serial.print(p2);
  Serial.print(p1);
  Serial.println();

  if (p1) {
    ToHigh(PIN1);
  } else {
    ToHigh(PIN1R);
  }

  if (p2) {
    ToHigh(PIN2);
  } else {
    ToHigh(PIN2R);
  }

  if (p3) {
    ToHigh(PIN3);
  } else {
    ToHigh(PIN3R);
  }

  if (p4) {
    ToHigh(PIN4);
  } else {
    ToHigh(PIN4R);
  }

  if (p5) {
    ToHigh(PIN5);
  } else {
    ToHigh(PIN5R);
  }

  if (p6) {
    ToHigh(PIN6);
  } else {
    ToHigh(PIN6R);
  }

  delay(500);
  CleanUp();
}


void CleanUp() {
  digitalWrite(PIN1, LOW);
  digitalWrite(PIN1R, LOW);

  digitalWrite(PIN2, LOW);
  digitalWrite(PIN2R, LOW);

  digitalWrite(PIN3, LOW);
  digitalWrite(PIN3R, LOW);

  digitalWrite(PIN4, LOW);
  digitalWrite(PIN4R, LOW);

  digitalWrite(PIN5, LOW);
  digitalWrite(PIN5R, LOW);

  digitalWrite(PIN6, LOW);
  digitalWrite(PIN6R, LOW);
}

void ToHigh(gpio_num_t pin) {
  digitalWrite(pin, HIGH);
}

void ToLow(gpio_num_t pin) {
  digitalWrite(pin, LOW);
}
