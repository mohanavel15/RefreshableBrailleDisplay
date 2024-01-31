# The Braille Project

To Run Mosquitto

```
$ mosquitto -c mosquitto.conf
```

Tesseract setup
```
$ apt install tesseract-ocr
$ apt install tesseract-ocr-tam
```

Conda Environment
```
$ conda env create -f environment.yml
```
export:
```
$ conda env export | grep -v "^prefix: " > environment.yml
```