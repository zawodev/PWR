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

int redBrightness = 0;
int greenBrightness = 0;
int blueBrightness = 0;

void setup() {
    lcd.init();
    lcd.backlight();

    Serial.begin(9600); // inicjalizacja portu szeregowego

    pinMode(LED_RED, OUTPUT);
    pinMode(LED_GREEN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);
}

void loop() {
    if (Serial.available() > 0) {
        String command = Serial.readStringUntil('\n'); // odczyt jednej linni komend
        command.trim(); // usuwanie białych znaków na początku i końcu
        command.toLowerCase(); // na małe litery

        if (command.startsWith("set")) {
            bool result = parseCommand(command);
            updateLEDs();
            if (result) {
                Serial.println("LEDs updated.");
            }
            else {
                Serial.println("Invalid command format.");
            }
        }
        else {
            Serial.println("Unknown command.");
        }
    }
}

bool parseCommand(String command) {
    int firstSpace = command.indexOf(' '); // find first space char
    int secondSpace = command.indexOf(' ', firstSpace + 1); // second
    int thirdSpace = command.indexOf(' ', secondSpace + 1); // third

    if (firstSpace != -1 && secondSpace != -1 && thirdSpace != -1) {
        redBrightness = command.substring(firstSpace + 1, secondSpace).toInt();
        greenBrightness = command.substring(secondSpace + 1, thirdSpace).toInt();
        blueBrightness = command.substring(thirdSpace + 1).toInt();
        return true;
    }
    return false;
}

void updateLEDs() {
    analogWrite(LED_RED, redBrightness);
    analogWrite(LED_GREEN, greenBrightness);
    analogWrite(LED_BLUE, blueBrightness);
}
