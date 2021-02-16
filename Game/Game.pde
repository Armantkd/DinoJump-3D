import processing.serial.Serial;
import processing.sound.*;
import java.util.ArrayList;
SoundFile sound;

int camX,camY,camZ;
int camTargX,camTargY,camTargZ;
int buttonPressed[] = {0,0,0,0};
PImage dinoImg,groundImg,groundTex,rockTex,sky,rockImg,shieldImg,gunImg,bubble,cactusImg,shadowImg;

ArrayList<PImage> clouds = new ArrayList<PImage>();
int tileRows = 10;
int tileCols = 20;
int tileSize = 1000;
PShape ground,rock;
float itemHeight = 0;

Serial port;
DinoJump dinoJump = new DinoJump();
ArrayList<ArrayList<PImage>> myDinoImgs = new ArrayList<ArrayList<PImage>>();
ArrayList<PImage> myGunImgs = new ArrayList<PImage>();
ArrayList<Integer> displayQ = new ArrayList<Integer>();

void makeBox(int x,int y,int z,int w,int h,int d,int r,int g,int b){   //makes a box at the given x,y,z with dimensions w,h,d and colour r,g,b
  fill(r,g,b);
  translate(x,y,z);
  box(w,h,d);
  translate(-x,-y,-z);
}

void drawImg(PImage img,int x,int y,int z,float rot){ 
  translate(x,y,z);
  rotateX(rot);
  image(img,0,0);
  rotateX(-rot);
  translate(-x,-y,-z);
}

void setupArduino() {
  if (port != null) {
    println("Disconnecting arduino...");
    port.dispose();
  }
  String[] ids = Serial.list();
  if (ids.length == 0) {
    println("No arduino detected");
    port = null;
    return;
  }
  print("Found " + ids.length + " serial port(s):");
  for (String id : ids)
    print(" " + id);
  println();
  String id = null;
  for (String i : ids) {
    if (i.contains("ACM")) {
      id = i;
      break;
    }
  }
  if (id == null) id = ids[ids.length - 1];
  println("Connecting to arduino on " + id + "...");
  try {
    port = new Serial(this, id, 9600);
    port.bufferUntil('\n');
    println("Connected!");
  } catch (Exception e) {
    println("Error: " + e);
    port = null;
  }
}

void setup(){                                                          //setup is called once when the program begins

 // frameRate(130);

  size(1280,720,P3D);                                                     //sets the window size to 1000 by 1000 pixels and sets the mode to 3D
  rectMode(CENTER);                                                        //makes it so that the point declared when making boxes defines the boxes center point (rather than topleft which is default)
  imageMode(CENTER);
  textSize(64);
  
  for(int i=0;i<2;i++){
    myDinoImgs.add(new ArrayList<PImage>());
  }
  for(int i=0;i<12;i++){
    myDinoImgs.get(0).add(loadImage("Data/Dino_Walk_" + str(i) + ".png"));
    myDinoImgs.get(0).get(i).resize(dinoJump.w,dinoJump.h);
  }
  for(int i=0;i<1;i++){
    myDinoImgs.get(1).add(loadImage("Data/Dino_Walk_0.png"));
    myDinoImgs.get(1).get(i).resize(dinoJump.w,dinoJump.h);
  }
  dinoJump.dinoImgs = myDinoImgs;
  
  
  for(int i=0;i<12;i++){
    myGunImgs.add(loadImage("Data/gun_"+str(i)+".png"));
    myGunImgs.get(i).resize(dinoJump.w,dinoJump.h);
  }
  
  clouds.add(loadImage("Data/cloud_0.png"));
  clouds.add(loadImage("Data/cloud_1.png"));
  clouds.add(loadImage("Data/cloud_2.png"));
  
  dinoJump.cloudImgBank = clouds;
  
  dinoJump.gunImgs = myGunImgs;
  
  sky = loadImage("Data/sky.jpg");
  sky.resize(width,height);
  dinoImg = loadImage("Data/dino.png");
  dinoImg.resize(200,200);
  groundImg = loadImage("Data/ground2.jpg");
  groundImg.resize(1000,1000);
  //groundTex = loadImage("Data/groundTex.jpg");
  //rockTex = loadImage("Data/rockTexBas.jpg");
  cactusImg = loadImage("Data/cactus.png");
  cactusImg.resize(300,500);
  
  rockImg = loadImage("Data/rock.png");
  rockImg.resize(300,200);
  
  shadowImg = loadImage("Data/shadow.png");
  shadowImg.resize(300,300);
  
  shieldImg = loadImage("Data/shield.png");
  shieldImg.resize(250,250);
  
  gunImg = loadImage("Data/gun.png");
  gunImg.resize(250,250);
  
  bubble = loadImage("Data/shield_0.png");
  bubble.resize(250,250);
  
  camX = 0;                                                                //sets the camera 100 ABOVE the origin
  camY = -275;                                                                 //by default, for the x, y, and z planes right, down, and inwards are positive
  camZ = 100;
  camTargX = 0;                                                            //sets the camera to look at the point 300 ahead of the origin
  camTargY = -275;
  camTargZ = -1000;
  

  //ground = loadShape("Data/floor3D.obj");
  //ground.setTexture(groundTex);
  //ground.scale(1.7,2,2);

  
  //rock = loadShape("Data/rock_base_LP2.obj");
  //rock.setTexture(rockTex);
  //rock.scale(0.5,0.5,0.5);
  //rock.rotateX(PI);
  
  

  setupArduino();
  sound = new SoundFile(this,"Dino.mp3");
}

int gameScreen=0;
void draw(){
  if (gameScreen==0){
    startScreen();
  }
  else if (gameScreen==1){
    gameScreen();
  }
  else if (gameScreen==2){
    gameOverScreen();
  }
  else if (gameScreen==3){
    pauseScreen();
  }
  
}                                                                          //when the draw function restarts the origin goes back to 0,0

void gameScreen(){
  dinoJump.tick();
  
  println((int)(random(500)-255));


  if ((sky.width != width) || (sky.height != height)){
    sky.resize(width,height);
  }
    
  background(sky);

  
  camera(camX+dinoJump.xPos,camY+dinoJump.yPos,camZ,camTargX+dinoJump.xPos,camTargY+dinoJump.yPos,camTargZ,0,1,0);                 //makes the camera with given position and target(0,1,0 is used to define which orientation is up, in this case "x0,y1,z0" y is up) 
  //makeBox(0,0,-50000,600,1,100000,255,255,255); 
  
/////////////////////////////////////////////////////////////////////////////
  translate(tileCols*tileSize/2,0,0);
  for (int i = 0;i < tileCols;i++){
    if (i != (tileCols/2)){
      translate(0,0,-dinoJump.position%1000);
      for (int j = 0;j < tileRows;j++){
        translate(0,0,-tileSize);
        rotateX(PI/2);
        image(groundImg,0,0);
        rotateX(-PI/2);
      }
      translate(0,0,tileSize*tileRows);
      translate(0,0,dinoJump.position%1000);
      translate(-tileSize,0,0);
    }
    else{
      translate(-tileSize,0,0);
    }
  }
  translate(tileCols*tileSize/2,0,0);
///////////////////////////////////////////////////////////////////////////// BELOW IS THE ULTRA NVIDIA HD MODE (VERY SLOW) COMMENT SECTION ON TOP BEFORE UNCOMMENTING
    //lightFalloff(1, 0, 0);
    //lightSpecular(0, 0, 0);
    //ambientLight(255, 255, 255);
    //directionalLight(255, 255, 255, 0, 0, -1);
    translate(0,0,-dinoJump.position%1000);
    for (int j = 0;j < tileRows;j++){
      translate(0,0,-tileSize);
      rotateX(PI/2);
      image(groundImg,0,0);
      rotateX(-PI/2);  
    }
    translate(0,0,tileSize*tileRows);
    translate(0,0,dinoJump.position%1000);
/////////////////////////////////////////////////////////////////////////////
  //makeBox(lanes[dinoJump.lane],dinoJump.yPos,-500,100,100,100,0,255,0);                     //draws the playerbox

  translate(-500+dinoJump.xPos, -700+dinoJump.yPos, -1000);
  rotateX(atan(1/12));
  text("distance",0,0,0);
  text(-dinoJump.position/1000, 0,64,0);    
  rotateX(atan(-1/12));
  translate(500-dinoJump.xPos, 700-dinoJump.yPos, 1000);
  
  itemHeight = (itemHeight+0.05)%100;
  
  int i = dinoJump.itemPos.size()-1;
  int j = dinoJump.obstaclePos.size()-1;
  int numCactus = 10;
  int numDino = 1;
  int lane = 0;
  int pos = 0;
  int nextQ = 0;

  while((i >= 0) || (j >= 0) || numCactus > 0 || numDino > 0 ){
    tint(255,255);
    nextQ = 0;
    if(i == -1){
      if(j == -1){
        if (numCactus == 0){
          nextQ = 3;
        }
        else nextQ = 2;
      }
      else nextQ = 1;
      }

    
    if ((nextQ == 0)&&(i != -1)&&(j != -1)&&(dinoJump.obstaclePos.get(j) <= dinoJump.itemPos.get(i)))nextQ = 1;
    
    if ((nextQ == 1)&&(-1000*numCactus-dinoJump.position%1000) <= dinoJump.obstaclePos.get(j)-dinoJump.position-700)  nextQ = 2;
    if ((nextQ == 0)&&(-1000*numCactus-dinoJump.position%1000) <= dinoJump.itemPos.get(i)-dinoJump.position-700)      nextQ = 2;
    
    if ((nextQ == 2)&&(numDino > 0)&&(-700 <= (-1000*numCactus-dinoJump.position%1000)))            nextQ = 3;
    if ((nextQ == 1)&&(j != -1)&&(numDino > 0)&&((-700 <= dinoJump.obstaclePos.get(j)-dinoJump.position-700)))                            nextQ = 3;
    if ((nextQ == 0)&&(i != -1)&&(numDino > 0)&&(-700 <= dinoJump.itemPos.get(i)-dinoJump.position-700))                                  nextQ = 3;


    
    if (nextQ == 0){
        lane = dinoJump.itemLane.get(i);
        pos = dinoJump.itemPos.get(i) - dinoJump.position;
        tint(255,min(255,max(0,(8000+pos)/4)));
        drawImg(shadowImg,dinoJump.lanes[0]+lane*dinoJump.lanes[2],dinoJump.ground-1,pos-700,PI/2);
        if(dinoJump.itemtype.get(i)== 0)
        drawImg(gunImg,dinoJump.lanes[0]+lane*dinoJump.lanes[2],(int)(sin(itemHeight)*-30-dinoJump.ground - 200),pos-700,0);
        else if (dinoJump.itemtype.get(i)== 1)
        drawImg(shieldImg,dinoJump.lanes[0]+lane*dinoJump.lanes[2],(int)(sin(itemHeight)*-30-dinoJump.ground - 200),pos-700,0); 
        i--;
    }
    if (nextQ == 1){
        lane = dinoJump.obstacleLane.get(j);
        pos = dinoJump.obstaclePos.get(j) - dinoJump.position;
        tint(255,min(255,max(0,(8000+pos)/4)));
        drawImg(shadowImg,dinoJump.lanes[0]+lane*dinoJump.lanes[2],dinoJump.ground-1,pos-700,PI/2);
        drawImg(rockImg,dinoJump.lanes[0]+lane*dinoJump.lanes[2],dinoJump.ground-200/2,pos-700,0);
        
        j--;
    }
    if (nextQ == 2){
       if (numCactus == 9) tint(255,-(dinoJump.position%1000)/4);
       drawImg(cactusImg,-550,-cactusImg.height/2,-1000*numCactus-dinoJump.position%1000,0);
       drawImg(cactusImg,550,-cactusImg.height/2,-1000*numCactus-dinoJump.position%1000,0);
       if (numCactus == 9) tint(255,255);
       numCactus--;
    }
    if (nextQ == 3){
        drawImg(shadowImg,dinoJump.xPos,dinoJump.ground-1,-700,PI/2);
        drawImg(dinoJump.dinoImgs.get(dinoJump.frameType).get(dinoJump.frameNum),dinoJump.xPos,dinoJump.yPos,-700,0);
        if (dinoJump.gun==1) drawImg(dinoJump.gunImgs.get(dinoJump.frameNum),dinoJump.xPos,dinoJump.yPos,-700,0);
        if(dinoJump.shield==1){
        fill(0,0,255);
        translate(500+dinoJump.xPos, -700+dinoJump.yPos, -1000);
        text("shield",0,0,0);
        text(dinoJump.shieldtimer, 0,64,0);   
        translate(-500-dinoJump.xPos, 700-dinoJump.yPos, 1000);
        drawImg(bubble,dinoJump.xPos,dinoJump.yPos,-700,0);
        }
        numDino--;
    }
  }
  int numClouds = dinoJump.cloudTimer.size();
  for(int k=0;k<numClouds;k++){
    if (dinoJump.cloudTimer.get(k) < 255){
      tint(255,dinoJump.cloudTimer.get(k));
    }
    if (dinoJump.cloudTimer.get(k) > 2500-255){
      tint(255,2500-dinoJump.cloudTimer.get(k));
    }
      
    drawImg(dinoJump.cloudImgs.get(k),dinoJump.xPos+(int)(dinoJump.cloudPositionX.get(k)),dinoJump.yPos-1500+(int)(dinoJump.cloudPositionY.get(k)),-3000,0);
    dinoJump.cloudPositionX.set(k,dinoJump.cloudPositionX.get(k)+dinoJump.cloudSpeedX.get(k));
    tint(255,255);
    dinoJump.cloudTimer.set(k,dinoJump.cloudTimer.get(k)+1);
    if ((dinoJump.cloudTimer.get(k)) > 2500){
      dinoJump.removeCloud(k);
      numClouds--;
      k--;
    }
  }

}
 
void startScreen(){
  background(0);
  textAlign(CENTER);
  textSize(30);
  translate(100,-35,0);
  text("Click to start.", height/2, width/2);
  translate(-100,35,0);
}

void startGame(){
  gameScreen=1;
}

void pauseScreen(){
  background(0);
  textAlign(CENTER);
  textSize(30);
  text("Click to continue.", height/2, width/2);
}

void continueGame(){
  gameScreen = 1;
}

void gameOverScreen(){
  camera();
  background(85,0,0);
  textAlign(CENTER);
  textSize(50);
  
  translate(100,-20);
  text("Distance: " + -dinoJump.position/1000 , height/2, width/2);
  translate(-100,20);
  
  textSize(60);
  translate(100,-150);
  text("Game Over", height/2, width/2);
  translate(-100, 150);
  
  translate(100,100);
  textSize(20);
  text("Click to Restart", height/2, width/2);
  translate(-100,-100);
}

void restart(){
  dinoJump = new DinoJump();
  dinoJump.dinoImgs = myDinoImgs;
  dinoJump.gunImgs = myGunImgs;
  dinoJump.cloudImgBank = clouds;
  gameScreen=1;
}

void keyPressed(){
  if (keyCode == RIGHT)
    dinoJump.moveRight();
  if (keyCode == LEFT)
    dinoJump.moveLeft();
  if (keyCode == UP)
    dinoJump.jump();
  if (keyCode == ENTER)
    gameScreen = 3;
  if (keyCode == ' ')
    dinoJump.shoot();
}

void serialEvent(Serial port) {
  String data = port.readStringUntil('\n'); // Read until end of line
  data = data.substring(0, data.length() - 2); // Trim the \n
  println("Controller says: " + data);
  if ("L".equals(data))
    dinoJump.moveLeft();
  if ("R".equals(data))
    dinoJump.moveRight();
  if ("J".equals(data))
    dinoJump.jump();
  if ("X".equals(data))
    dinoJump.shoot();
}
