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

int currentColor = 0; // 0 - czerwona, 1 - zielona, 2 - niebieska
int lastDebounceTimeRed = 0;
int lastDebounceTimeGreen = 0;
int debounceDelay = 50;

bool lastRedButtonState = HIGH;
bool lastGreenButtonState = HIGH;
bool redButtonPressed = false;
bool greenButtonPressed = false;

void initRGB() {
  pinMode(LED_RED, OUTPUT);
  digitalWrite(LED_RED, LOW);

  pinMode(LED_GREEN, OUTPUT);
  digitalWrite(LED_GREEN, LOW);

  pinMode(LED_BLUE, OUTPUT);
  digitalWrite(LED_BLUE, LOW);
}

void initButtons() {
  pinMode(RED_BUTTON, INPUT_PULLUP);
  pinMode(GREEN_BUTTON, INPUT_PULLUP);
}

void changeColor() {
  // zmiana na kolejny kolor
  currentColor = (currentColor + 1) % 3;
  // włącz odpowiednią diodę wyłącz inną
  if (currentColor == 0) {
      digitalWrite(LED_BLUE, LOW);
      digitalWrite(LED_RED, HIGH);
  }
  else if (currentColor == 1) {
      digitalWrite(LED_RED, LOW);
      digitalWrite(LED_GREEN, HIGH);
  }
  else if (currentColor == 2) {
      digitalWrite(LED_GREEN, LOW);
      digitalWrite(LED_BLUE, HIGH);
  }
}

void handleButtonPress(int buttonPin, bool &lastButtonState, bool &buttonPressed, int &lastDebounceTime) {
  bool reading = digitalRead(buttonPin);

  // sprawdzenie eliminacji drgań
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    // tylko po ustabilizowaniu sygnału traktujemy to jako prawdziwy przycisk
    if (reading == LOW && !buttonPressed) { // naciśnięcie
      buttonPressed = true;
    } else if (reading == HIGH && buttonPressed) { // zwolnienie
      buttonPressed = false;

      // akcja po zwolnieniu przycisku
      if (buttonPin == GREEN_BUTTON) {
        changeColor(); // zmiana koloru
      }
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
  // obsługa czerwonego przycisku
  handleButtonPress(RED_BUTTON, lastRedButtonState, redButtonPressed, lastDebounceTimeRed);

  // obsługa zielonego przycisku
  handleButtonPress(GREEN_BUTTON, lastGreenButtonState, greenButtonPressed, lastDebounceTimeGreen);
}
