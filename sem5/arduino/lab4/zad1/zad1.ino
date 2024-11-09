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

void setup() {
    lcd.init();
    lcd.backlight();

    pinMode(RED_BUTTON, INPUT_PULLUP);
    pinMode(GREEN_BUTTON, INPUT_PULLUP);

    Serial.begin(9600);
    // 115200
    // max 4 000 000
    // rozpoczęcie komunikacji szeregowej z maksymalną szybkością 115200 bps
    //page 3
    //https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf
}

void loop() {
    int redButtonState = digitalRead(RED_BUTTON);
    int greenButtonState = digitalRead(GREEN_BUTTON);

    // wysyłanie danych do komputera
    Serial.print("RED_BUTTON:");
    Serial.print(redButtonState);
    Serial.print("\tGREEN_BUTTON:");
    Serial.println(greenButtonState);

    delay(100);
}
