#include <Adafruit_NeoPixel.h>
#define PIN 6

const int strip_size = 288;
Adafruit_NeoPixel strip;

void setup(){
  Serial.begin(500000);
  strip = Adafruit_NeoPixel(strip_size, PIN, NEO_GRB + NEO_KHZ800);
  strip.begin();
  strip.show();
}

int r, g, b;

void loop(){
  if(Serial.available() > 0){
    for(int i = 0; i < strip_size; i++){
      r = Serial.parseInt();
      g = Serial.parseInt();
      b = Serial.parseInt();
      strip.setPixelColor(i, r, g, b);
      if(Serial.read() != '\n'){
        break;
      }
    }
    strip.show();
  }
}
