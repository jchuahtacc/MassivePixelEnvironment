import peasy.*;
PeasyCam cam;

// MPE includes
import mpe.Process;
import mpe.Configuration;

// MPE Process thread
Process process;

// MPE Configuration object
Configuration tileConfig;

boolean stallion = false;
float rotX = 0.0;
float rotY = 0.0;
float rotZ = 0.0;
float stallionScale = 1.0;

void settings() {
  if (stallion) {
    // create a new configuration object and specify the path to the configuration file
    tileConfig = new Configuration(dataPath("configuration.xml"), this);
    
    // set the size of the sketch based on the configuration file
    size(tileConfig.getLWidth(), tileConfig.getLHeight(), OPENGL);
  } else {
    size(200, 200, P3D);
  }
}

void setup() {
  if (stallion) {
    // create a new configuration object and specify the path to the configuration file
    tileConfig = new Configuration(dataPath("configuration.xml"), this);
    
    // set the size of the sketch based on the configuration file
    size(tileConfig.getLWidth(), tileConfig.getLHeight(), OPENGL);
    // create a new process
    process = new Process(tileConfig);
  
  // disable camera placement by MPE, because it interferes with PeasyCam
    process.disableCameraReset();
    stallionScale = 100.0;
  }
  
  // initialize the peasy cam
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  
  if (stallion) {
    if(tileConfig.isLeader())
       strokeWeight(.1);
  
    // start the MPE process
    process.start();
  }
}

void draw() {
  // synchronize this process' camera with the headnode
  if (stallion) {
    if(process.messageReceived())
    {
      // set the animation time to 0, otherwise we get weird behavior
      cam.setState((CameraState) process.getMessage(), 0);
    }  
  }
  
  // draw a couple boxes
  scale(stallionScale);
  
  background(0);
  directionalLight(255, 0, 0, 0, 1, -1);
  directionalLight(0, 0, 255, 0, 0, -1);
  directionalLight(0, 255, 0, -1, 0, 0);
  directionalLight(255, 255, 255, 1, 1, 1);
  fill(255, 255, 255);
  pushMatrix();
  rotateY(-PI / 6.0);
  rotateZ(-PI / 6.0);

  rotateX(-PI * rotX);
  box(30);
  translate(0, 0, 30);
  noStroke();
  sphere(10);
  popMatrix();
  rotX = (rotX + 0.01) % 2.0;
  rotY = (rotY + 0.01) % 2.0;
  rotZ = (rotZ + 0.01) % 2.0;
}


// when the master process receives a mouse event, broadcast the update camera state to the other processes
void mouseDragged()
{
  if (stallion) {
    process.broadcast(cam.getState());
  }
}