#include <Wire.h>
#include <RTClib.h>

RTC_DS1307 RTC;

int ledPin = 2;         // Set our LED pin

byte startHour = 20;    // Set our start and end times
byte startMinute = 24;  // Don't add leading zero to hour or minute - 7, not 07
byte endHour = 20;      // Use 24h format for the hour, without leading zero
byte endMinute = 25;

byte validStart = 0;    // Declare and set to 0 our start flag
byte poweredOn = 0;     // Declare and set to 0 our current power flag
byte validEnd = 0;      // Declare and set to 0 our end flag

void setup () {
  pinMode(ledPin, OUTPUT);   // Set our LED as an output pin
  digitalWrite(ledPin, LOW); // Set the LED to LOW (off)
  
  Wire.begin();              // Start our wire and real time clock
  RTC.begin();
  
  if (! RTC.isrunning()) {                       // Make sure RTC is running
    Serial.println("RTC is NOT running!");
    //RTC.adjust(DateTime(__DATE__, __TIME__));  // Uncomment to set the date and time
  }
}

void loop () {
  
  DateTime now = RTC.now(); // Read in what our current datestamp is from RTC
  
  if (now.second() == 0) { // Only process if we have ticked over to new minute
    if (poweredOn == 0) {  // Check if lights currently powered on
      checkStartTime();    // If they are not, check if it's time to turn them on
    } else {
      checkEndTime();      // Otherwise, check if it's time to turn them off
    }
  
    if (validStart == 1) { // If our timer is flagged to start, turn the lights on
      turnLightsOn();
    }
    if (validEnd == 1) {   // If our time is flagged to end, turn the lights off
      turnLightsOff();
    }
  }
  
  delay(1000);  
}

byte checkStartTime() {
  DateTime now = RTC.now();  // Read in what our current datestamp is from RTC
  
  if (now.hour() == startHour && now.minute() == startMinute) {
    validStart = 1;  // If our start hour and minute match the current time, set 'on' flags
    poweredOn = 1;
  } else {
    validStart = 0;  // Otherwise we don't need to power up the lights yet
  }
  
  return validStart; // Return the status for powering up
} 

byte checkEndTime() {
  DateTime now = RTC.now();  // Read in what our current datestamp is from RTC
  
  if (now.hour() == endHour && now.minute() == endMinute) {
    validEnd = 1;    // If our end hour and minute match the current time, set the 'off' flags
    poweredOn = 0;
  } else {
    validEnd = 0;    // Otherwise we don't need to power off the lights yet
  }
  
  return validEnd;   // Return the status for powering off
} 

void turnLightsOn() {
  digitalWrite(ledPin, HIGH);  // Turn on the LED
}

void turnLightsOff() {
  digitalWrite(ledPin, LOW);   // Turn off the LED
}
