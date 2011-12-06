import processing.video.*;
import deadpixel.keystone.*;

//keystone:
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;

//camera:
Capture cam;

//mode toggles
boolean go = false;
boolean expose = false;
boolean preFlash = false;

//settings:
int exposureTime =  4000;
int preFlashTime = 0;

//global variables
float startExposureAt;
float lastExposureAt = -5000;
float keyPressedAt = 0;
int blinkTime;
int[] brightArray = new int[3072];


void setup() {
  size(1280, 960, P3D); 
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(640, 480, 20);
  background(0);
  cam = new Capture(this, 64, 48);
  offscreen = createGraphics(640, 480, P2D);
  //cam.start(); 
}

void draw() {
 
  PVector surfaceMouse = surface.getTransformedMouse();
  offscreen.beginDraw();
  offscreen.background(0);
  background(0);
  offscreen.fill(0, 255, 0);
  offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
  offscreen.endDraw();

  
  
  if (go) {
    if (cam.available()) {
      offscreen.background(0);
      cam.read();
      println("Taking photo");
      int camPixels[] = cam.pixels;
      for (int i = 0; i < brightArray.length; i++)
      {
        brightArray[i] = int(map(brightness(camPixels[i]), 0, 255, 0, exposureTime));
      }
      go = false;
      preFlash = true;
    }
  }

  if (preFlash) {
    offscreen.background(255);
    if (millis() > keyPressedAt + preFlashTime) {
      preFlash = false;
      expose = true;
    }
  }


  if (expose)   
  {
    for (int i = 0; i < cam.width * cam.height; i++)
    {
      int y = i/cam.width;
      int x = cam.width - 1 - i%cam.width;


      if (millis() - startExposureAt < brightArray[i]) { // method #1 (time since hit with light matters)
        //if (startExposureAt + exposureTime - millis() < brightArray[i]) {    //method #2 (amount of time hit matters)
        int rand = int(random(3));
        if (rand == 0) {
          offscreen.fill(0, 0, 255);
        }
        if (rand == 1) {
          offscreen.fill(255, 0, 255);
        }
        if (rand ==2) {
          offscreen.fill(255, 255, 255);
        }
      }
      else {
        int rand = int(random(3));
        if (rand == 0)
        {
          offscreen.fill(255, 0, 0);
        }
        else if (rand == 1)
        {
          offscreen.fill(0, 255, 0);
        }
        else if (rand ==2)
        {
          offscreen.fill(255, 255, 0);
        }
      }

      offscreen.noStroke();
      offscreen.rect(x * 10, y * 10, 10, 10);
    }
  }

  if ( millis() > startExposureAt + exposureTime)
  {
    offscreen.background(0);
    expose = false;
  }
  surface.render(offscreen);
}

void keyPressed() {
  
    switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // & moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
    
  default:
      keyPressedAt = millis();
      startExposureAt = millis() + preFlashTime;
      go = true;
      expose = false;
      break;
  }
}

