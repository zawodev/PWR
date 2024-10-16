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

#define RED_BUTTON 2
#define GREEN_BUTTON 4

const unsigned long debounceDelay = 50;
unsigned long lastDebounceTimeRed = 0;
unsigned long lastDebounceTimeGreen = 0;

int currentColor = 0; // 0 - czerwona, 1 - zielona, 2 - niebieska

bool lastRedButtonState = HIGH;
bool lastGreenButtonState = HIGH;
bool redButtonPressed = false;
bool greenButtonPressed = false;

void initRGB() {
  const int ledPins[] = {LED_RED, LED_GREEN, LED_BLUE};
  for (int i = 0; i < 3; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW);
  }
}

void initButtons() {
  const int buttonPins[] = {RED_BUTTON, GREEN_BUTTON};
  for (int i = 0; i < 2; i++) {
    pinMode(buttonPins[i], INPUT_PULLUP);
  }
}

void changeColor() {
  const int ledPins[] = {LED_RED, LED_GREEN, LED_BLUE};
  digitalWrite(ledPins[currentColor], LOW);
  currentColor = (currentColor + 1) % 3;
  digitalWrite(ledPins[currentColor], HIGH);
}

void handleButtonPress(int buttonPin, bool &lastButtonState, bool &buttonPressed, unsigned long &lastDebounceTime) {
  bool reading = digitalRead(buttonPin);

  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading == LOW && !buttonPressed) {
      buttonPressed = true;
    }
    else if (reading == HIGH && buttonPressed) {
      buttonPressed = false;
      changeColor();
    }
  }

  lastButtonState = reading;
}

void setup() {
  initRGB();
  initButtons();

  // na start RED color
  digitalWrite(LED_RED, HIGH);
}

void loop() {
  handleButtonPress(RED_BUTTON, lastRedButtonState, redButtonPressed, lastDebounceTimeRed);
  handleButtonPress(GREEN_BUTTON, lastGreenButtonState, greenButtonPressed, lastDebounceTimeGreen);
}
