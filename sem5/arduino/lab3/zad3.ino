#include <Wire.h>
#include <LiquidCrystal_I2C.h>

#define GREEN_BUTTON 4 // klawisz zielony
#define RED_BUTTON 2   // klawisz czerwony

LiquidCrystal_I2C lcd(0x27, 16, 2); // ustawienia LCD

unsigned long startTime = 0;        // czas startu stopera
unsigned long elapsedTime = 0;      // czas, który upłynął
bool running = false;               // czy stoper działa?

void initButtons() {
  pinMode(GREEN_BUTTON, INPUT_PULLUP);
  pinMode(RED_BUTTON, INPUT_PULLUP);
}

void updateDisplay() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Time:");

  lcd.setCursor(0, 1);
  lcd.print(elapsedTime / 1000); // konwersja na sekundy
  lcd.print(" sec");
}

void setup() {
  lcd.begin(16, 2); // rozpoczęcie komunikacji z wyświetlaczem
  lcd.backlight();

  initButtons();
  updateDisplay(); // wyświetl 0 na starcie
}

void loop() {
  if (digitalRead(GREEN_BUTTON) == LOW) {
    delay(50); // debounce
    if (digitalRead(GREEN_BUTTON) == LOW) { // weryfikacja ponowna po eliminacji
      if (!running) {
        running = true;              // uruchomienie stopera
        startTime = millis() - elapsedTime; // kontynuacja od ostatniego miejsca
      } else {
        running = false;             // zatrzymanie stopera
        elapsedTime = millis() - startTime; // zaktualizowanie upływu czasu
      }
      updateDisplay(); // aktualizacja wyświetlacza
      while (digitalRead(GREEN_BUTTON) == LOW); // oczekiwanie na zwolnienie przycisku
    }
  }

  if (digitalRead(RED_BUTTON) == LOW) {
    delay(50); // eliminacja drgań styków
    if (digitalRead(RED_BUTTON) == LOW) { // weryfikacja ponowna po eliminacji
      running = false;        // zatrzymanie stopera
      elapsedTime = 0;        // resetowanie upływu czasu
      updateDisplay();        // aktualizacja wyświetlacza
      while (digitalRead(RED_BUTTON) == LOW); // oczekiwanie na zwolnienie przycisku
    }
  }

  if (running) {
    elapsedTime = millis() - startTime; // aktualizacja upływu czasu podczas działania stopera
    if (elapsedTime % 1000 == 0) {      // aktualizacja wyświetlacza co sekundę
      updateDisplay();
    }
  }
}
