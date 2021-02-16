#include <Wire.h>

// Resources:
// https://www.youtube.com/watch?v=KMhbV1p3MWk

// ADXL345 sensor I2C address
#define MPU 0x68
#define PIN_BUTTON 2

#define JUMP_DELAY 500
#define MOVE_THRESHOLD 2500
#define MOVE_DELAY 1500

struct vec3s {
  int16_t x, y, z;
};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); // Enable serial communication
  while (!Serial); // Wait until serial is available
  delay(50);

  Wire.begin(); // Create Wire Object
  Wire.beginTransmission(MPU);
  Wire.write(0x6B); // Access POWER_MGMT_1 register
  Wire.write(0); // Set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
  delay(50);

  pinMode(PIN_BUTTON, INPUT);
}

int16_t readShortBE() {
  int16_t b = (uint16_t) Wire.read() << 8;
  b |= Wire.read();
  return b;
}

long moveCooldown = 0;

void loop() {
  long tm = millis();

  // Read accelerometer data
  Wire.beginTransmission(MPU);
  Wire.write(0x3B); // Start with register ACCEL_XOUT_H
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true); // Read 14 registers total
  vec3s accel, gyro;
  accel.x = readShortBE();
  accel.y = readShortBE();
  accel.z = readShortBE();
  int16_t temp = readShortBE();
  gyro.x = readShortBE();
  gyro.y = readShortBE();
  gyro.z = readShortBE();

//  Serial.print("Accel ");
//  Serial.print(accel.x); Serial.print(", ");
//  Serial.print(accel.y); Serial.print(", ");
//  Serial.print(accel.z); Serial.print("  Gyro ");
//  Serial.print(gyro.x); Serial.print(", ");
//  Serial.print(gyro.y); Serial.print(", ");
//  Serial.print(gyro.z); Serial.println();

  if (accel.z > 25000) {
    Serial.println("J");
    moveCooldown = tm + JUMP_DELAY;
//    Serial.println(accel.z);
  }

  if (tm >= moveCooldown) {
    if (gyro.x < -MOVE_THRESHOLD) {
      Serial.println("L");
      moveCooldown = tm + MOVE_DELAY;
    } else if (gyro.x > MOVE_THRESHOLD) {
      Serial.println("R");
      moveCooldown = tm + MOVE_DELAY;
    }
  }

  delay(20);
//  Serial.print("Gyro: ");
//  Serial.print(gyro.x); Serial.print(", ");
//  Serial.print(gyro.y); Serial.print(", ");
//  Serial.println(gyro.z);

  int button = digitalRead(PIN_BUTTON);
  if (button) {
    Serial.println("X");
  }
}
