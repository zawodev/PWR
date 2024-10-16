#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);
OneWire oneWire(A1);
DallasTemperature sensors(&oneWire);

#define LED_RED 6
#define LED_GREEN 5
#define LED_BLUE 3

unsigned long previousMillisRed = 0;
unsigned long previousMillisGreen = 0;
unsigned long previousMillisBlue = 0;

const unsigned long intervalRed = 900;    // RED
const unsigned long intervalGreen = 1000; // GREEN
const unsigned long intervalBlue = 1100;  // BLUE

bool redState = LOW;
bool greenState = LOW;
bool blueState = LOW;

void initRGB() {
  pinMode(LED_RED, OUTPUT);
  digitalWrite(LED_RED, LOW);

  pinMode(LED_GREEN, OUTPUT);
  digitalWrite(LED_GREEN, LOW);

  pinMode(LED_BLUE, OUTPUT);
  digitalWrite(LED_BLUE, LOW);
}

void setup() {
  initRGB();
}

void changeLED(int currentMillis, int& previousMillis, const unsigned long interval, bool& state, int led) {
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    state = !state;
    digitalWrite(led, state);
  }
}

void loop() {
  unsigned long currentMillis = millis();

    changeLED(currentMillis, previousMillisRed, intervalRed, redState, LED_RED);
    changeLED(currentMillis, previousMillisGreen, intervalGreen, greenState, LED_GREEN);
    changeLED(currentMillis, previousMillisBlue, intervalBlue, blueState, LED_BLUE);

  //kolejne zadania dla loopa tutaj
}
