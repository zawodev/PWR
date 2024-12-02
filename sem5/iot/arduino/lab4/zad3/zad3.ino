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

#define POTENTIOMETER_PIN A0 // pin do odczytu potencjometru
#define VOLTAGE_REF 5.0 // napięcie

void setup() {
    Serial.begin(9600);
    lcd.init();
    lcd.backlight();

    lcd.print("ADC:");
    lcd.setCursor(0, 1);
    lcd.print("Voltage:");
}

void loop() {
    int adcValue = analogRead(POTENTIOMETER_PIN); // odczyt ADC
    float voltage = (adcValue / 1023.0) * VOLTAGE_REF; // konwersja na napięcie

    // LCD
    lcd.setCursor(5, 0);
    lcd.print(adcValue);
    lcd.print("    "); // kasowanie ewentualnych starych cyfr
    lcd.setCursor(9, 1);
    lcd.print(voltage, 2);
    lcd.print("V");

    // zad 4 - debugowanie w serial
    Serial.print("ADC:");
    Serial.print(adcValue);
    Serial.print("\tVoltage:");
    Serial.print(voltage, 2);
    Serial.println("V");

    delay(100);
}