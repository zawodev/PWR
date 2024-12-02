//
// Created by aliks on 19.11.2024.
//
#include "RGBLED.h"

// konstruktor
RGBLED::RGBLED(int red, int green, int blue) {
    red_pin = red;
    green_pin = green;
    blue_pin = blue;
}

// inicjalizacja pinów
void RGBLED::begin() {
    pinMode(red_pin, OUTPUT);
    pinMode(green_pin, OUTPUT);
    pinMode(blue_pin, OUTPUT);
    setColor(BLACK); // wyłączenie diody na start
}

// funkcja pomocnicza do ustawienia PWM na pinach
void RGBLED::writeColor(int red_value, int green_value, int blue_value) {
    analogWrite(red_pin, red_value);
    analogWrite(green_pin, green_value);
    analogWrite(blue_pin, blue_value);
}

// ustawienie koloru przez wartości RGB
void RGBLED::setColor(int red_value, int green_value, int blue_value) {
    writeColor(red_value, green_value, blue_value);
}

// ustawienie koloru przez nazwę
void RGBLED::setColor(Color color) {
    switch (color) {
        case RED:
            writeColor(255, 0, 0);
            break;
        case GREEN:
            writeColor(0, 255, 0);
            break;
        case BLUE:
            writeColor(0, 0, 255);
            break;
        case YELLOW:
            writeColor(255, 255, 0);
            break;
        case CYAN:
            writeColor(0, 255, 255);
            break;
        case MAGENTA:
            writeColor(255, 0, 255);
            break;
        case BLACK:
            writeColor(0, 0, 0);
            break;
        case WHITE:
            writeColor(255, 255, 255);
            break;
    }
}
