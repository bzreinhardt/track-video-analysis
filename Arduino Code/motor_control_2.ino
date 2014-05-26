
#include <Time.h>  

const int ledPin = 13;      // LED
const int buttonPin = 4;    // switch input
const int pot1Pin = 0; // potentiometer pin to control motor 1
const int pot2Pin = 0; // potentiometer pin to control motor 2
const int motor1L = 5;    // Motor 1 leg 1 (pin 2, 1A)
const int motor1R = 6;    // Motor 1 leg 2 (pin 7, 2A)
const int motor2L = 10;    // Motor 2 leg 1 (pin 2, 1A)
const int motor2R = 11;    // Motor 2 leg 2 (pin 7, 2A)
const int lockPin = 1; //sense pin for locking the motors together

 int motor_speed = 255;   // Max value of PWM
 int button = 0;
 int lock = 0; // if lock is low, motors are independent
 int potMax = 1023;
 int pot1In = 0;
 int pot2In = 0;
 int mot1L = 0;
 int mot1R = 0;
 int mot2L = 0;
 int mot2R = 0;

void setup()
{
 
  // set the inputs:
    pinMode(buttonPin, INPUT); 
    pinMode(pot1Pin, INPUT);
    pinMode(pot2Pin, INPUT);
    pinMode(lockPin, INPUT);

    // set all the other pins you're using as outputs:
    pinMode(motor1L, OUTPUT); 
    pinMode(motor1R, OUTPUT);
    pinMode(motor2L, OUTPUT); 
    pinMode(motor2R, OUTPUT);  
    pinMode(ledPin, OUTPUT);
  
  blink(ledPin, 3, 50); 
  Serial.begin(9600);
}

void loop()
{
  /////////////
  // SENSE //
 //Find what values each H bridge leg should be (based on sensors etc)
 pot1In = analogRead(pot1Pin);
 pot2In = analogRead(pot2Pin);
 lock = digitalRead(lockPin);
//////////////////////
// GENERATE COMMANDS //
 // Find commands for Motor 1
 // Note: motor speed is zero in the middle of the potentiometer range
 // Emergency off at the ends of the range
 if (pot1In == 0 || pot1In == potMax)
 {
  mot1R = 0;
  mot1L = 0;
}
 else if(pot1In >= potMax/2){
 // if pot value is in top half of range, spin right
  mot1R = (pot1In-potMax/2)/2; 
  mot1L = 0;

 }
 else {
 // if pot value is in the bottom half or range, spin left
  mot1R = 0; 
  mot1L = (potMax/2-pot1In)/2;

 }

  // Find commands for Motor 2
 // Note: motor speed is zero in the middle of the potentiometer range
 // Emergency off at the ends of the range
 if (lock == HIGH){
  mot2R = mot1R;
  mot2L = mot1L;
 }
 else if (pot2In == 0 || pot2In == potMax)
 {
  mot2R = 0;
  mot2L = 0;
 }
 else if(pot2In >= potMax/2){
 // if pot value is in top half of range, spin right
  mot2R = (pot2In-potMax/2)/2; 
  mot2L = 0;
 }
 else {
 // if pot value is in the bottom half or range, spin left
  mot2R = 0; 
  mot2L = (potMax/2-pot2In)/2;
 }
 ///////////////////////////////////////
 // SEND COMMANDS //
 // Set the values for each H bridge
 //motor 1

 if (mot1L != 0){
  analogWrite(motor1L, mot1L);
  digitalWrite(motor1R,LOW);
 }
 else{
  analogWrite(motor1R, mot1R);
  digitalWrite(motor1L,LOW);
 } 
  
 //Right motor
 if (mot2L != 0){
  analogWrite(motor2L, mot2L);
  digitalWrite(motor2R,LOW);
 }
 else{
  analogWrite(motor2R, mot2R);
  digitalWrite(motor2L,LOW);
 } 
/*
//  // Serial reading for debugging
// //Serial.print("pot1 ");
// Serial.print(pot1In);
// Serial.print("\t");
// Serial.print("pot2 ");
// Serial.print(pot2In);
// Serial.print("\t");
// Serial.print("Mot1 ");
// Serial.print(mot1R);
// Serial.print("\t");
// Serial.print(mot1L);
// Serial.print("\t");
// Serial.print("Mot2 ");
// Serial.print(mot2R);
// Serial.print("\t");
// Serial.print(mot2L);
// Serial.print("\n");
// blink(ledPin, 1, 100); 
// }
// */

Serial.print(millis());
Serial.print("\t");
//Serial.print("Mot1 \t");

Serial.print(mot1R);
Serial.print("\t");
Serial.print(mot1L);
Serial.print("\t");
//Serial.print("Mot2 \t");

Serial.print(mot2R);
Serial.print("\t");
Serial.print(mot2L);
Serial.print("\n");
//NOTE potentiometer goes from 0 to 1023
}

void blink(int whatPin, int howManyTimes, int milliSecs) 
{
    int i = 0;
    for ( i = 0; i < howManyTimes; i++)
    {
      digitalWrite(whatPin, HIGH);
      delay(milliSecs/2);
      digitalWrite(whatPin, LOW);
      delay(milliSecs/2);
    }
  }

void cmdMotor(int pinL, int pinR, int cmdL, int cmdR)
{
   if (cmdL != 0){
  analogWrite(pinL, cmdL);
  digitalWrite(pinR,LOW);
 }
 else{
  analogWrite(pinR, cmdR);
  digitalWrite(pinL, LOW);
 } 
}
