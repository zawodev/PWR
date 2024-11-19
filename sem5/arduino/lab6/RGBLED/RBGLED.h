//
// Created by aliks on 19.11.2024.
//

#ifndef RGBLED_H
#define RGBLED_H

#include <Arduino.h>

// predefiniowane kolory
enum Color {
    RED,
    GREEN,
    BLUE,
    YELLOW,
    CYAN,
    MAGENTA,
    BLACK,
    WHITE
};

class RGBLED {
private:
    int red_pin;
    int green_pin;
    int blue_pin;

    // funkcja pomocnicza do ustawienia kolorów
    void writeColor(int red_value, int green_value, int blue_value);

public:
    // konstruktor
    RGBLED(int red, int green, int blue);

    // inicjalizacja pinów
    void begin();

    // ustawienie koloru przez wartości RGB
    void setColor(int red_value, int green_value, int blue_value);

    // ustawienie koloru przez nazwę
    void setColor(Color color);
};

#endif
