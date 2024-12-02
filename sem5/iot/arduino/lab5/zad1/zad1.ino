#include <LiquidCrystal_I2C.h>

#define LED_RED 6
#define LED_BLUE 3

#define ENCODER1 A2
#define ENCODER2 A3
#define DEBOUNCE_TIME 100

LiquidCrystal_I2C lcd(0x27, 16, 2);

int encoderValue = 0;
int lastEn1 = LOW;
unsigned long lastChangeTimestamp = 0UL;

// SEKWENCJA W PRAWO: 00 -> 01 -> 11 -> 10 -> 00
// SEKWENCJA W LEWO:  00 -> 10 -> 11 -> 01 -> 00

void printResults(int val) {
    char buffer[40];
    sprintf(buffer, "Encoder: %3d", val);
    lcd.setCursor(2, 0);
    lcd.print(buffer);
}

void myAction(int val) {
    printResults(val);
    analogWrite(LED_RED, val);
    analogWrite(LED_BLUE, 255 - val);
}

void setup() {
    pinMode(LED_RED, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);
    pinMode(ENCODER1, INPUT_PULLUP);
    pinMode(ENCODER2, INPUT_PULLUP);

    lcd.init();
    lcd.backlight();
    myAction(0);
}

void loop() {
    int en1 = digitalRead(ENCODER1);
    int en2 = digitalRead(ENCODER2);

    unsigned long timestamp = millis();

    // if ENCODER1 zmieni się z HIGH na LOW
    if (en1 == LOW && lastEn1 == HIGH && timestamp > lastChangeTimestamp + DEBOUNCE_TIME) {
        // ENCODER2 wskazuje kierunek obrotu
        // HIGH - w prawo, LOW - w lewo
        if (en2 == HIGH) {
            if (encoderValue < 255) encoderValue += 15;
        }
        else {
            if (encoderValue > 0) encoderValue -= 15;
        }

        lastChangeTimestamp = timestamp;
        myAction(encoderValue);
    }

    lastEn1 = en1;
}
