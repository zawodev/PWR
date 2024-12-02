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

#define COMFORT_MIN 26.0
#define COMFORT_MAX 28.0

float min_temp = 1000.0;
float max_temp = -1000.0; 

enum DisplayMode { CURRENT_TEMP, MIN_MAX_TEMP };
DisplayMode current_mode = CURRENT_TEMP;

void setup() {
    lcd.init();
    lcd.backlight();

    sensors.begin();

    pinMode(LED_RED, OUTPUT);
    pinMode(LED_GREEN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);

    pinMode(RED_BUTTON, INPUT_PULLUP);
    pinMode(GREEN_BUTTON, INPUT_PULLUP);

    lcd.setCursor(0, 0);
    lcd.print("Initializing...");
    delay(2000);
}

void loop() {
    sensors.requestTemperatures();
    float internal_temp = sensors.getTempCByIndex(1); // temperatura wewnętrzna
    float external_temp = sensors.getTempCByIndex(0); // temperatura zewnętrzna

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
