#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>

LiquidCrystal_I2C lcd(0x27,16,2);

OneWire oneWire(A1);
DallasTemperature sensors(&oneWire);

#define LED_RED 6    // pin czerwonej diody
#define LED_GREEN 5  // pin zielonej diody
#define LED_BLUE 3   // pin niebieskiej diody

int redValue = 255;    // początkowa wartość czerwonej diody
int greenValue = 0;    // początkowa wartość zielonej diody
int blueValue = 0;     // początkowa wartość niebieskiej diody

int fadeSpeed = 5;     // szybkość zmiany kolorów (im wyższa wartość, tym wolniej)

void setup() {
  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);
}

void loop() {
  // od czerwonego do żółtego (zielony wzrasta)
  for (int i = 0; i <= 255; i++) {
    greenValue = i;           // zwiększamy zieloną wartość
    updateColor(redValue, greenValue, blueValue);
    delay(fadeSpeed);               // opóźnienie dla płynnego przejścia
  }

  greenValue = 255;  // zielona wartość pozostaje maksymalna

  // od żółtego do zielonego (czerwony maleje)
  for (int i = 255; i >= 0; i--){
    redValue = i;            // zmniejszamy czerwoną wartość
    updateColor(redValue, greenValue, blueValue);
    delay(fadeSpeed);
  }

  redValue = 0;

  // od zielonego do niebieskiego (niebieski wzrasta)
  for (int i = 0; i <= 255; i++) {
    blueValue = i;           // zwiększamy niebieską wartość
    updateColor(redValue, greenValue, blueValue);
    delay(fadeSpeed);
  }

  blueValue = 255;         // niebieska wartość pozostaje maksymalna

  // od niebieskiego do cyjanu (zielony maleje)
  for (int i = 255; i >= 0; i--) {
    greenValue = i;          // zmniejszamy zieloną wartość
    updateColor(redValue, greenValue, blueValue);
    delay(fadeSpeed);
  }

  greenValue = 0;

  // od cyjanu do niebieskiego (czerwony wzrasta)
  for (int i = 0; i <= 255; i++) {
    redValue = i;            // zwiększamy czerwoną wartość
    updateColor(redValue, greenValue, blueValue);
    delay(fadeSpeed);
  }

  redValue = 255;

  // od niebieskiego do fioletowego (niebieski maleje)
  for (int i = 255; i >= 0; i--) {
    blueValue = i;           // zmniejszamy niebieską wartość
    updateColor(redValue, greenValue, blueValue);
    delay(fadeSpeed);
  }

  blueValue = 0;
}

// funkcja aktualizująca kolor diody rgb
void updateColor(int red, int green, int blue) {
  analogWrite(LED_RED, red);     // ustawienie jasności czerwonej diody
  analogWrite(LED_GREEN, green); // ustawienie jasności zielonej diody
  analogWrite(LED_BLUE, blue);   // ustawienie jasności niebieskiej diody
}

