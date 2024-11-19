#include <RGBLED.h>

// dioda RGB podłączona do pinów 9, 10, 11
RGBLED led(6, 5, 3);

void setup() {
    led.begin(); // inicjalizacja diody

    // ustawienie kolorów
    led.setColor(RED);    // czerwony
    delay(1000);
    led.setColor(GREEN);  // zielony
    delay(1000);
    led.setColor(BLUE);   // niebieski
    delay(1000);

    // mieszanie kolorów przez wartości RGB
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
