#include <RGBLED.h>

// dioda RGB podłączona do pinów a, b, c
RGBLED led(6, 5, 3);

void setup() {
    led.begin(); // inicjalizacja diody

    // ustawienie kolorów
    led.setColor(RED);
    delay(1000);
    led.setColor(GREEN);
    delay(1000);
    led.setColor(BLUE);
    delay(1000);

    led.setColor(128, 64, 0); // pomarańczowy
    delay(1000);

    led.setColor(BLACK); // wyłączenie diody
}

void loop() {
    // cykliczne wyświetlanie kolorów
    led.setColor(CYAN);
    delay(1000);
    led.setColor(MAGENTA);
    delay(1000);
    led.setColor(WHITE);
    delay(1000);
}
