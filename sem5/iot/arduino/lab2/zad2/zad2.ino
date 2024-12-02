#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>

LiquidCrystal_I2C lcd(0x27,16,2);

OneWire oneWire(A1);
DallasTemperature sensors(&oneWire);

#define LED_GREEN 5  // zielona dioda

#define RED_BUTTON 2 // czerwony przycisk
#define GREEN_BUTTON 4 // zielony przycisk

int brightness = 0;        // początkowa jasność diody (od 0 do 255)
const int fadeAmount = 5;  // zmiana jasnosci przy każdym naciśnięciu

void initLED() {
  pinMode(LED_GREEN, OUTPUT);
  analogWrite(LED_GREEN, brightness); // ustawienie początkowej jasności diody na 0
}

void initButtons() {
  pinMode(RED_BUTTON, INPUT_PULLUP);
  pinMode(GREEN_BUTTON, INPUT_PULLUP);
}

void setup() {
  initLED();
  initButtons();
}

void loop() {
  // zielony przycisk - rozjaśnianie diody
  if (digitalRead(GREEN_BUTTON) == LOW) {
    delay(50);
    brightness = brightness + fadeAmount; // zwiększamy jasność
    if (brightness > 255) {
      brightness = 255; // clamp the value
    }
    analogWrite(LED_GREEN, brightness); // ustawienie nowej jasności na diodzie
  }

  // czerwony przycisk - sciemnia diode
  if (digitalRead(RED_BUTTON) == LOW) {
    delay(50);
    brightness = brightness - fadeAmount; // zmniejszamy jasność
    if (brightness < 0) {
      brightness = 0; // clamp
    }
    analogWrite(LED_GREEN, brightness); // ustawienie nowej jasności
  }

  delay(50); // mała przerwa na odczyt kolejnych naciśnięć
}
