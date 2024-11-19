#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// inicjalizacja LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

// inicjalizacja czujnika temperatury
OneWire oneWire(A1);
DallasTemperature sensors(&oneWire);

// piny dla diody RGB
#define LED_RED 6
#define LED_GREEN 5
#define LED_BLUE 3

// piny przycisków
#define RED_BUTTON 2
#define GREEN_BUTTON 4

// zakres strefy komfortu
#define COMFORT_MIN 20.0
#define COMFORT_MAX 25.0

// zmienne do przechowywania wartości minimalnej i maksymalnej temperatury
float min_temp = 1000.0; // start z wysoką wartością
float max_temp = -1000.0; // start z niską wartością

// tryb wyświetlania
enum DisplayMode { CURRENT_TEMP, MIN_MAX_TEMP };
DisplayMode current_mode = CURRENT_TEMP;

void setup() {
    // inicjalizacja LCD
    lcd.init();
    lcd.backlight();

    // inicjalizacja czujników temperatury
    sensors.begin();

    // ustawienie pinów diody RGB
    pinMode(LED_RED, OUTPUT);
    pinMode(LED_GREEN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);

    // ustawienie pinów przycisków
    pinMode(RED_BUTTON, INPUT_PULLUP);
    pinMode(GREEN_BUTTON, INPUT_PULLUP);

    // wyświetlenie początkowego komunikatu
    lcd.setCursor(0, 0);
    lcd.print("Initializing...");
    delay(2000);
}

void loop() {
    // odczyt temperatury z czujników
    sensors.requestTemperatures();
    float internal_temp = sensors.getTempCByIndex(1); // temperatura wewnętrzna
    float external_temp = sensors.getTempCByIndex(0); // temperatura zewnętrzna

    // aktualizacja min/max dla temperatury zewnętrznej
    if (external_temp < min_temp) {
        min_temp = external_temp;
    }
    if (external_temp > max_temp) {
        max_temp = external_temp;
    }

    // obsługa przycisków
    if (digitalRead(RED_BUTTON) == LOW) {
        current_mode = CURRENT_TEMP;
        delay(100); // debouncing
    } else if (digitalRead(GREEN_BUTTON) == LOW) {
        current_mode = MIN_MAX_TEMP;
        delay(100); // debouncing
    }

    // wyświetlanie na LCD w zależności od trybu
    lcd.clear();
    if (current_mode == CURRENT_TEMP) {
        lcd.setCursor(0, 0);
        lcd.print("Int: ");
        lcd.print(internal_temp, 1);
        lcd.print("C");
        lcd.setCursor(0, 1);
        lcd.print("Ext: ");
        lcd.print(external_temp, 1);
        lcd.print("C");

        // sygnalizacja strefy komfortu diodą RGB
        if (external_temp < COMFORT_MIN) {
            setRGB(0, 0, 255); // niebieski
        } else if (external_temp > COMFORT_MAX) {
            setRGB(255, 0, 0); // czerwony
        } else {
            setRGB(0, 255, 0); // zielony
        }
    } else if (current_mode == MIN_MAX_TEMP) {
        lcd.setCursor(0, 0);
        lcd.print("Min: ");
        lcd.print(min_temp, 1);
        lcd.print("C");
        lcd.setCursor(0, 1);
        lcd.print("Max: ");
        lcd.print(max_temp, 1);
        lcd.print("C");

        // wyłączanie diody RGB w tym trybie
        setRGB(0, 0, 0);
    }

    delay(100); // zmniejszenie częstotliwości odświeżania
}

// funkcja ustawiająca kolor diody RGB
void setRGB(int red, int green, int blue) {
    analogWrite(LED_RED, red);
    analogWrite(LED_GREEN, green);
    analogWrite(LED_BLUE, blue);
}
