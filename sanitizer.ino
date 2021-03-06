#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WiFiMulti.h> 
#include <ESP8266mDNS.h>
#include <ESP8266WebServer.h>
#include <FastLED.h>

#define ACTIVATION_DELAY 10*1000
#define UVC_DURATION 15*60*1000
#define BUTTON_DEBOUNCE_DUR 100

#define LED_PIN 2 //Define blinking LED pin
#define UVC_PIN 14
#define BUTTON_PIN 0
#define RGB_LED_PIN 4
#define NUM_LEDS 1
#define MOTION_SENSOR_PIN 5

ESP8266WiFiMulti wifiMulti;     // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'
ESP8266WebServer server(80);    // Create a webserver object that listens for HTTP request on port 80

#include "./networks.h"

CRGB leds[NUM_LEDS];

int buttonDownTime = 0;
bool lastButton = false;
boolean connectionWasAlive = true;

int timeInUVC = 0;
int stateEntered = 0;
enum states{READY, ACTIVATING, UVC};
enum states state = READY;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  pinMode(UVC_PIN, OUTPUT);
  pinMode(MOTION_SENSOR_PIN, INPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  Serial.begin(115200);

  setupNetworks();

  FastLED.addLeds<WS2812, RGB_LED_PIN, GRB>(leds, NUM_LEDS);

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
  if (state == UVC) {
    timeInUVC += timeInState();
  }
  if (newState == READY) {
    timeInUVC = 0;
  }
  Serial.printf("entering state %d\r\n", newState);
  state = newState;
  resetStateEntered();
}

void resetStateEntered() {
  stateEntered = millis();
}

int timeInState() {
  return millis() - stateEntered;
}

void updateLEDs(bool motion) {
  CRGB color;
  bool flashing = false;
  
  if (state == READY) {
    color = CRGB ( 0, 0, 255);
  } else if (state == UVC) {
    color = CRGB ( 255, 0, 0);
    flashing = true;
  } else if (state == ACTIVATING) {
    color = CRGB ( 255,150, 0);
    flashing = true;
  }
  
  if (motion && (state == READY || state == ACTIVATING)) {
    color = CRGB ( 0, 255, 0);
  } 

  FastLED.setBrightness(flashing ? 255 : 100);

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
  bool motion = digitalRead(MOTION_SENSOR_PIN) == HIGH;
  if (motion) {
    digitalWrite(LED_PIN, LOW); // Turn the LED on (Note that LOW is the voltage level)
  } else {
    digitalWrite(LED_PIN, HIGH); // Turn the LED off by making the voltage HIGH
  }

  if (state == UVC) {
    digitalWrite(UVC_PIN, HIGH); // turn UVC on
  } else {
    digitalWrite(UVC_PIN, LOW); // turn UVC off
  }
  bool curButton = digitalRead(BUTTON_PIN) == LOW && timeInState() >= 1000;
  // button edge trigger on release
  bool buttonPress = curButton && !lastButton;
  if (buttonPress) {
    buttonDownTime = millis();
  }
  bool button = !curButton && lastButton && (millis() - buttonDownTime) > BUTTON_DEBOUNCE_DUR;
  lastButton = curButton;

  if ((state == UVC || state == ACTIVATING) && button) {
    setState(READY);
  } else if (state == UVC && motion) {
    setState(ACTIVATING);
  } else if (state == ACTIVATING && motion) {
    resetStateEntered();
  } else if (state == READY && button) {
    setState(ACTIVATING);
  } else if (state == ACTIVATING && timeInState() > ACTIVATION_DELAY) {
    setState(UVC);
  } else if (state == UVC && timeInUVC > UVC_DURATION) {
    setState(READY);
  } 

  updateLEDs(motion);
  monitorWiFi();
}
