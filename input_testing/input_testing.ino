// SPDX-FileCopyrightText: 2026 Randall Frank
// SPDX-License-Identifier: MIT

#include <EEPROM.h>

// Target: 
//  Arduino Pro Micro
// Connections: 
//  AS5600 Analog Mode (A0) 
//  Pushbutton connected to ground using internal pullups (A2)

const int ANALOG_PIN = A0;
const int BUTTON_PIN = A2;

// Minimum angle step change (0..1023) required to trigger an update (effectively 0-256 -> 0-360)
const int ANGLE_CHANGE_THRESHOLD = 4;

// Debounce timing (ms)
const unsigned long DEBOUNCE_DELAY_MS = 30;

// Button state tracking (active LOW with INPUT_PULLUP)
int lastRawButtonState = HIGH;
int debouncedButtonState = HIGH;
unsigned long lastDebounceTime = 0;

// Angle state tracking
int lastAngle = -1;

// Angle 'zero' positions
int zeroAngle0 = 0;
int zeroAngle1 = 0;

void setup() {
  pinMode(ANALOG_PIN, INPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  Serial.begin(115200);
  unsigned long startWait = millis();
  while (!Serial && (millis() - startWait < 3000)) {
    ;
  }

  Serial.println("AS5600 Analog (0-1023) + Button Monitor Started");

  debouncedButtonState = digitalRead(BUTTON_PIN);
  lastRawButtonState = debouncedButtonState;
  lastAngle = analogRead(ANALOG_PIN);

// If the pushbutton is down for 3s on startup, save the current angle as the 'zero' position
  startWait = millis();
  while ((debouncedButtonState == LOW) && (millis() - startWait < 3000)) {
    debouncedButtonState = digitalRead(BUTTON_PIN);
    // Write the 'zero' points to the first 4 bytes of the EEPROM (PDL0 - 16bits, PDL1 - 16bits)
    zeroAngle0 = analogRead(ANALOG_PIN);
    zeroAngle1 = analogRead(ANALOG_PIN);
    EEPROM.put(0, zeroAngle0);
    EEPROM.put(2, zeroAngle1);

    Serial.println("Angle zero values updated");
  }

  // Read the 'zero' angle values
  EEPROM.get(0, zeroAngle0);
  EEPROM.get(2, zeroAngle1);

  // In case the zero value was uninitialized, clamp it [0,1023]
  zeroAngle0 = zeroAngle0 & 0x03ff;
  zeroAngle1 = zeroAngle1 & 0x03ff;

  Serial.print("Zero Angle 0: ");
  Serial.print(zeroAngle0);
  Serial.print("| Zero Angle 1: ");
  Serial.println(zeroAngle1);

  Serial.print("Initial Angle: ");
  Serial.print(lastAngle);
  Serial.print(" | Button: ");
  Serial.println(debouncedButtonState == LOW ? "PRESSED" : "RELEASED");

}

void loop() {
  unsigned long now = millis();

  // 1. Read and debounce pushbutton on A2
  int rawButton = digitalRead(BUTTON_PIN);
  bool buttonChanged = false;

  if (rawButton != lastRawButtonState) {
    lastDebounceTime = now;
    lastRawButtonState = rawButton;
  }

  if ((now - lastDebounceTime) >= DEBOUNCE_DELAY_MS) {
    if (rawButton != debouncedButtonState) {
      debouncedButtonState = rawButton;
      buttonChanged = true;
    }
  }

  // 2. Read AS5600 analog value on A0 (0..1023)
  int currentAngle = analogRead(ANALOG_PIN);
  int angleDelta = abs(currentAngle - lastAngle);
  bool angleChanged = (lastAngle < 0) || (angleDelta >= ANGLE_CHANGE_THRESHOLD);

  // 3. Print whenever angle value or debounced button state changes
  if (buttonChanged || angleChanged) {
    lastAngle = currentAngle;

    Serial.print("Angle: ");
    Serial.print(lastAngle);
    Serial.print(" | Value: ");
    Serial.print(remap(lastAngle, zeroAngle0));
    Serial.print(" | Button: ");
    Serial.println(debouncedButtonState == LOW ? "PRESSED" : "RELEASED");
  }
}

// Apply the zero offset and wrap it around 12bits [0,1023]
int remap(int sensor, int zero) {
  return (sensor - zero) & 0x03ff;
}
