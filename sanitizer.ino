#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WiFiMulti.h> 
#include <ESP8266mDNS.h>
#include <ESP8266WebServer.h>
#include <FastLED.h>


#define LED 2 //Define blinking LED pin
#define BUTTON 0
#define RGB_LED 4
#define NUM_LEDS 1
#define MOTION_SENSOR 5

ESP8266WiFiMulti wifiMulti;     // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'
ESP8266WebServer server(80);    // Create a webserver object that listens for HTTP request on port 80

#include "./networks.h"

CRGB leds[NUM_LEDS];

bool motion = false;
bool button = false;
boolean connectionWasAlive = true;

int stateEntered = 0;
enum states{READY, MOTION, ACTIVATING, UVC};
enum states state = READY;

void setup() {
  pinMode(LED, OUTPUT); // Initialize the LED pin as an output
  pinMode(MOTION_SENSOR, INPUT);
  pinMode(BUTTON, INPUT_PULLUP);

  Serial.begin(115200);

  setupNetworks();

  FastLED.addLeds<WS2812, RGB_LED, GRB>(leds, NUM_LEDS);

  server.on("/activate", HTTP_POST, postActivate);
  server.on("/", HTTP_GET, getDebug);

  setState(READY);
}

void postActivate() {
  if (state == READY) {
    setState(ACTIVATING);
    server.send(200, "text/html", "activating!");
  } else {
    server.send(500, "text/html", "can't activate, state="+String(state));
  }
}

void getDebug() {
  server.send(200, "application/json", 
  "{\"state\": "+String(state)+", \"state_entered\": "+String(millis() - stateEntered)+"}");
}

int lastLogged = 0;

void monitorWiFi() {
  if (wifiMulti.run() != WL_CONNECTED){
    if (connectionWasAlive) {
      connectionWasAlive = false;
      Serial.print("Looking for WiFi ");
    }
    int now = millis();
    if ((now - lastLogged) > 1000) {
      Serial.print(".");
      lastLogged = now;
    }
  } else {
    if (!connectionWasAlive) {
      connectionWasAlive = true;
      Serial.printf(" connected to %s\n", WiFi.SSID().c_str());
  
      server.begin();
      if (MDNS.begin("sanitizer")) {
        Serial.println("mDNS responder started");
      } else {
        Serial.println("Error setting up MDNS responder!");
      }
    }
    
    server.handleClient(); 
  }
}

void setState(enum states newState) {
  if (newState == state) {
    return;
  }
  Serial.printf("entering state %d\r\n", newState);
  state = newState;
  stateEntered = millis();
}

int timeInState() {
  return millis() - stateEntered;
}

void updateLEDs() {
  CRGB color;
  bool flashing = false;
  
  if (state == READY) {
    color = CRGB ( 0, 0, 255);
  } else if (state == MOTION) {
    color = CRGB ( 0, 255, 0);
  } else if (state == UVC) {
    color = CRGB ( 255, 0, 0);
    flashing = true;
  } else if (state == ACTIVATING) {
    color = CRGB ( 255,150, 0);
    flashing = true;
  }
  if (flashing && ((millis() / 250) % 2 == 0)) {
    color = CRGB(0,0,0);
  }
  for (int i = 0; i<NUM_LEDS; i++) {
    leds[i] = color;
  }
  
  FastLED.show();
}

// the loop function runs over and over again forever
void loop() {
  motion = digitalRead(MOTION_SENSOR) == HIGH;
  if (motion) {
    digitalWrite(LED, LOW); // Turn the LED on (Note that LOW is the voltage level)
  } else {
    digitalWrite(LED, HIGH); // Turn the LED off by making the voltage HIGH
  }

  button = digitalRead(BUTTON) == LOW && timeInState() >= 1000;

  if (motion) {
    setState(MOTION);
  } else if (state == MOTION && !motion) {
    setState(READY);
  } else if (state == READY && button) {
    setState(ACTIVATING);
  } else if (state == ACTIVATING && timeInState() > 10000) {
    setState(UVC);
  } else if (state == UVC && timeInState() > 5*60*1000) {
    setState(READY);
  } else if ((state == UVC || state == ACTIVATING) && button) {
    setState(READY);
  }

  updateLEDs();
  monitorWiFi();
}
