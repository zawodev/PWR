#include <util/atomic.h>
#include <LiquidCrystal_I2C.h>

#define LED_RED 6
#define LED_GREEN 5
#define LED_BLUE 3
#define ENCODER1 A2
#define ENCODER2 A3
#define BUTTON_GREEN 4
#define BUTTON_RED 2

#define DEBOUNCING_PERIOD 100
#define LED_VAL_STEP 5

LiquidCrystal_I2C lcd(0x27, 16, 2);

// ------------------------ ENUMS ------------------------

enum MenuState { MainMenu, EditLedMenu, SetColorMenu };
MenuState currentMenu = MainMenu;

// ------------------------ MENU ------------------------

const char* mainMenu[] = {
        "Edit LED Red",
        "Edit LED Green",
        "Edit LED Blue",
        "Set Color",
        "Reset"
};
const int mainMenuLength = sizeof(mainMenu) / sizeof(mainMenu[0]);

// ------------------------ COLOR MENU ------------------------

const char* colorMenu[] = {
        "Set Orange",
        "Set Sea",
        "Set Purple",
        "Set Cyan",
        "Set Yellow",
        "Set Magenta"
};
const int colorMenuLength = sizeof(colorMenu) / sizeof(colorMenu[0]);

// ------------------------ VARIABLES ------------------------

volatile int encoderValue = 0; //temp for encoder value

int menuIndex = 0;
int lastMainMenuIndex = 0;

int ledValue = 0; //temp value for editing
int redLedValue = 0, greenLedValue = 0, blueLedValue = 0;

// ------------------------ FUNCTIONS ------------------------

void applyLedValues() {
    analogWrite(LED_RED, redLedValue);
    analogWrite(LED_GREEN, greenLedValue);
    analogWrite(LED_BLUE, blueLedValue);
}

void setPresetColor(int colorIndex) {
    switch (colorIndex) {
        case 0: redLedValue = 255; greenLedValue = 130; blueLedValue = 0; break;   // Orange
        case 1: redLedValue = 0; greenLedValue = 255; blueLedValue = 140; break;   // Sea
        case 2: redLedValue = 120; greenLedValue = 0;   blueLedValue = 255; break; // Purple
        case 3: redLedValue = 0;   greenLedValue = 255; blueLedValue = 255; break; // Cyan
        case 4: redLedValue = 255; greenLedValue = 255; blueLedValue = 0; break;   // Yellow
        case 5: redLedValue = 255; greenLedValue = 0;   blueLedValue = 255; break; // Magenta
    }
}

void displayMenu(const char* menu[], int menuLength, int index) {
    lcd.clear();
    int firstLineIndex = index % menuLength;
    int secondLineIndex = (index + 1) % menuLength;

    lcd.setCursor(0, 0);
    lcd.print("->");
    lcd.print(menu[firstLineIndex]);

    lcd.setCursor(0, 1);
    lcd.print("  ");
    lcd.print(menu[secondLineIndex]);
}

void enterEditLedMenu(const char* ledName, int& currentLedValue) {
    ledValue = currentLedValue;
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(ledName);
    lcd.setCursor(0, 1);
    lcd.print("Value: ");
    lcd.print(ledValue);
}

void updateLedBrightness() {
    switch (menuIndex) {
        case 0: redLedValue = ledValue; break;
        case 1: greenLedValue = ledValue; break;
        case 2: blueLedValue = ledValue; break;
    }
    applyLedValues();
}

// ------------------------ SETUP ------------------------

void setup() {
    pinMode(LED_RED, OUTPUT);
    pinMode(LED_GREEN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);
    pinMode(ENCODER1, INPUT_PULLUP);
    pinMode(ENCODER2, INPUT_PULLUP);
    pinMode(BUTTON_GREEN, INPUT_PULLUP);
    pinMode(BUTTON_RED, INPUT_PULLUP);

    lcd.init();
    lcd.backlight();
    displayMenu(mainMenu, mainMenuLength, menuIndex);

    PCICR |= (1 << PCIE1);
    PCMSK1 |= (1 << PCINT10);
}

// ------------------------ INTERRUPT SERVICE ROUTINE ------------------------

volatile int encoder1 = HIGH;
volatile int encoder2 = HIGH;
volatile unsigned long encoderTimestamp = 0UL;

ISR(PCINT1_vect) {
    encoder1 = digitalRead(ENCODER1);
    encoder2 = digitalRead(ENCODER2);
    encoderTimestamp = millis();
}

// ------------------------ MAIN LOOP ------------------------

void loop() {

    unsigned long timestamp;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
        timestamp = encoderTimestamp;
    }

    // ------------------------ BUTTON GREEN ------------------------

    if (digitalRead(BUTTON_GREEN) == LOW) {
        delay(100);
        if (currentMenu == MainMenu) {
            lastMainMenuIndex = menuIndex; // save current index before switching menu
            if (menuIndex < 3) {
                currentMenu = EditLedMenu;
                if (menuIndex == 0) enterEditLedMenu(mainMenu[menuIndex], redLedValue);
                else if (menuIndex == 1) enterEditLedMenu(mainMenu[menuIndex], greenLedValue);
                else if (menuIndex == 2) enterEditLedMenu(mainMenu[menuIndex], blueLedValue);
            }
            else if (menuIndex == 3) {
                currentMenu = SetColorMenu;
                menuIndex = 0;
                displayMenu(colorMenu, colorMenuLength, menuIndex);
            }
            else if (menuIndex == 4) {
                redLedValue = greenLedValue = blueLedValue = 0;
                applyLedValues();
                displayMenu(mainMenu, mainMenuLength, menuIndex);
            }
        }
        else if (currentMenu == SetColorMenu) {
            setPresetColor(menuIndex);
            applyLedValues(); // apply changes after setting color
            currentMenu = MainMenu;
            menuIndex = lastMainMenuIndex; // return to the last position in the main menu
            displayMenu(mainMenu, mainMenuLength, menuIndex);
        }
        else if (currentMenu == EditLedMenu) {
            updateLedBrightness();
            currentMenu = MainMenu;
            menuIndex = lastMainMenuIndex; // return to the last position in the main menu
            displayMenu(mainMenu, mainMenuLength, menuIndex);
        }
    }

    // ------------------------ BUTTON RED ------------------------

    if (digitalRead(BUTTON_RED) == LOW) {
        delay(100);
        if (currentMenu == EditLedMenu || currentMenu == SetColorMenu) {
            currentMenu = MainMenu;
            menuIndex = lastMainMenuIndex; // return to the last position in the main menu
            displayMenu(mainMenu, mainMenuLength, menuIndex);
        }
    }

    // ------------------------ ENCODER ------------------------

    int en1 = encoder1;
    int en2 = encoder2;
    if (en1 == LOW && millis() > timestamp + DEBOUNCING_PERIOD) {
        if (en2 == HIGH) {
            if (currentMenu == MainMenu) {
                menuIndex = (menuIndex + 1) % mainMenuLength;
                displayMenu(mainMenu, mainMenuLength, menuIndex);
            }
            else if (currentMenu == SetColorMenu){
                menuIndex = (menuIndex + 1) % colorMenuLength;
                displayMenu(colorMenu, colorMenuLength, menuIndex);
            }
            else if (currentMenu == EditLedMenu && ledValue < 255) {
                ledValue += LED_VAL_STEP;
                enterEditLedMenu(mainMenu[menuIndex], ledValue);
            }
        }
        else {
            if (currentMenu == MainMenu) {
                menuIndex = (menuIndex - 1 + mainMenuLength) % mainMenuLength;
                displayMenu(mainMenu, mainMenuLength, menuIndex);
            }
            else if (currentMenu == SetColorMenu) {
                menuIndex = (menuIndex - 1 + colorMenuLength) % colorMenuLength;
                displayMenu(colorMenu, colorMenuLength, menuIndex);
            }
            else if (currentMenu == EditLedMenu && ledValue > 0) {
                ledValue -= LED_VAL_STEP;
                enterEditLedMenu(mainMenu[menuIndex], ledValue);
            }
        }
        encoderTimestamp = millis();
    }
}
