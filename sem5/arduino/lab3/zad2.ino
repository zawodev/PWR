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
  const int ledPins[] = {LED_RED, LED_GREEN, LED_BLUE};
  for (int i = 0; i < 3; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW);
  }
}

void setup() {
    lcd.init();
    lcd.backlight();

  initRGB();
}

void changeLED(unsigned long currentMillis, unsigned long& previousMillis, const unsigned long interval, bool& state, const int led) {
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    state = !state;
    digitalWrite(led, state);

    //nie jest konieczne, ale do debugowania fajne
    displayLEDState();
  }
}

void displayLEDState() {
  lcd.clear(); // clear the LCD screen
  lcd.setCursor(0, 0); // set cursor to the beginning
  lcd.print("(");
  lcd.print(redState);  // print red LED state
  lcd.print(", ");
  lcd.print(greenState); // print green LED state
  lcd.print(", ");
  lcd.print(blueState);  // print blue LED state
  lcd.print(")");
}

void loop() {
    unsigned long currentMillis = millis();
    changeLED(currentMillis, previousMillisRed, intervalRed, redState, LED_RED);
    changeLED(currentMillis, previousMillisGreen, intervalGreen, greenState, LED_GREEN);
    changeLED(currentMillis, previousMillisBlue, intervalBlue, blueState, LED_BLUE);

    //kolejne zadania dla loopa tutaj

}
