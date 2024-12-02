#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>

LiquidCrystal_I2C lcd(0x27,16,2);

OneWire oneWire(A1);
DallasTemperature sensors(&oneWire);

#define LED_RED 6
#define LED_GREEN 5
#define LED_BLUE 3

#define RED_BUTTON 2
#define GREEN_BUTTON 4

bool isOn = false; // stan diody (włączona/wyłączona)
int currentColor = 0; // 0 - czerwona, 1 - zielona, 2 - niebieska

void initRGB()
{
  pinMode(LED_RED, OUTPUT);
  digitalWrite(LED_RED, LOW);

  pinMode(LED_GREEN, OUTPUT);
  digitalWrite(LED_GREEN, LOW);

  pinMode(LED_BLUE, OUTPUT);
  digitalWrite(LED_BLUE, LOW);
}

void initButtons()
{
  pinMode(RED_BUTTON, INPUT_PULLUP); //czerwony przycisk włączania/wyłączania diod
  pinMode(GREEN_BUTTON, INPUT_PULLUP); //zielony przycisk zmiany koloru
}

void setup()
{
  initRGB();
  initButtons();
}

void loop()
{
  // sprawdzenie czy czerwony przycisk jest wcisniety
  if (digitalRead(RED_BUTTON) == LOW)
  {
    delay(100); //czas na odskoczenie przy wciskaniu przycisku
    isOn = !isOn; // zmienia stan włączona/wyłączona
  }

  // sprawdzenie czy zielony przycisk jest wcisniety
  if (digitalRead(GREEN_BUTTON) == LOW)
  {
    delay(100); // czas na odskoczenie przy wciskaniu przycisku
    currentColor = (currentColor + 1) % 3; // cykliczne przełączanie między 0, 1 i 2
  }

  // kontrolowanie koloru diody w zależności od stanu przycisków
  if (isOn)
  {
    switch (currentColor)
    {
      case 0: // czerwona
        digitalWrite(LED_RED, HIGH);
        digitalWrite(LED_GREEN, LOW);
        digitalWrite(LED_BLUE, LOW);
        break;
      case 1: // zielona
        digitalWrite(LED_RED, LOW);
        digitalWrite(LED_GREEN, HIGH);
        digitalWrite(LED_BLUE, LOW);
        break;
      case 2: // niebieska
        digitalWrite(LED_RED, LOW);
        digitalWrite(LED_GREEN, LOW);
        digitalWrite(LED_BLUE, HIGH);
        break;
    }
  }
  else
  {
    // gdy dioda wyłączona, gasimy wszystkie
    digitalWrite(LED_RED, LOW);
    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_BLUE, LOW);
  }

  delay(100); // krótka przerwa aby uniknąć nadmiernego odpytywania
}
