#include <Wire.h>
#include <LiquidCrystal_I2C.h>

#define GREEN_BUTTON 4
#define RED_BUTTON 2

LiquidCrystal_I2C lcd(0x27, 16, 2);

unsigned long startTime = 0;
unsigned long elapsedTime = 0;
bool running = false; // czy stoper działa? w sensie czy liczy czas

const unsigned long debounceDelay = 50;

// red button
bool redButtonPressed = false;
unsigned long lastDebounceTimeRed = 0;

// green button
bool greenButtonPressed = false;
unsigned long lastDebounceTimeGreen = 0;

void initButtons() {
  pinMode(GREEN_BUTTON, INPUT_PULLUP);
  pinMode(RED_BUTTON, INPUT_PULLUP);
}

void updateDisplay() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Time:");

  lcd.setCursor(0, 1);
  int minutes = elapsedTime / 60000;
  int seconds = (elapsedTime % 60000) / 1000;
  int milliseconds = elapsedTime % 1000;

  if (minutes < 10) {
      lcd.print("0");
  }
  lcd.print(minutes);
  lcd.print(":");

  if (seconds < 10) {
      lcd.print("0");
  }
  lcd.print(seconds);
  lcd.print(":");

  if (milliseconds < 100) {
      lcd.print("0");
  }
  if (milliseconds < 10) {
      lcd.print("0");
  }
  lcd.print(milliseconds);
}

void setup() {
  lcd.init();
  lcd.backlight();

  initButtons();
  updateDisplay(); //wyświetl 0 na starcie
}

void handleButtonPress(const int buttonPin, const unsigned long debounceDelay, bool &buttonPressed, unsigned long &lastDebounceTime, void (*action)()) {
  bool currentState = digitalRead(buttonPin);
  unsigned long currentTime = millis();

  if (currentState != buttonPressed) {
    lastDebounceTime = currentTime; // reset the debounce timer
  }

  if ((currentTime - lastDebounceTime) > debounceDelay) {
    if (currentState == LOW && !buttonPressed) {
        buttonPressed = true;
        //button pressed action here
        action();
    }
    else if (currentState == HIGH && buttonPressed) {
        buttonPressed = false;
        //button released action here
    }
  }
}

void toggleTimer() {
  if (!running) {
    running = true;
    startTime = millis() - elapsedTime;
  }
  else {
    running = false;
    elapsedTime = millis() - startTime;
  }
  updateDisplay();
}

void resetTimer() {
  running = false;
  elapsedTime = 0;
  updateDisplay();
}

void loop() {
  handleButtonPress(RED_BUTTON, debounceDelay, redButtonPressed, lastDebounceTimeRed, resetTimer);
  handleButtonPress(GREEN_BUTTON, debounceDelay, greenButtonPressed, lastDebounceTimeGreen, toggleTimer);

  if (running) {
    elapsedTime = millis() - startTime;
    if (elapsedTime % 213 == 0) {
      updateDisplay();
    }
  }
}