public class DinoJump {
  // Speed of the game (number of pixels to move forward each frame)
  public int lanes[] = {-300,0,300};
  public int zVel = 15;
  
  // Position of the dinosaur. The dinosaur walks forward automatically, so this variable increases automatically.
  // This also functions as the player's score.
  public int position = 0;
  // Current lane
  public int lane = 1;
  public int shield = 0;
  public int shieldtimer=0;
  public int shieldsub=0;
  public int gun = 0 ;
  public int gunpos=0;
  public int guntimer=0;
  public int ground = 0;
  public int w = 200;
  public int h = 200*1500/831; //ratio of height to width is 1500/831
  public int xPos = 0;
  public int xVel = zVel;
  public int yPos = ground - h/2;
  public int yVel = 0;
  public int yAccel = 1;
  
  public ArrayList<ArrayList<PImage>> dinoImgs = new ArrayList<ArrayList<PImage>>();
  public int frameNums[] = {12,1};
  public int frameType = 0;
  public int frameNum = 0;
  
  // Lane of each obstacle (each element is 0, 1, or 2)
  public ArrayList<Integer> obstacleLane = new ArrayList<Integer>();
  // Position of each obstacle
  public ArrayList<Integer> obstaclePos = new ArrayList<Integer>();
  
  public ArrayList<Integer> itemLane = new ArrayList<Integer>();
  public ArrayList<Integer> itemPos = new ArrayList<Integer>();
  public ArrayList<Integer> itemtype = new ArrayList<Integer>();
  
  public ArrayList<PImage> gunImgs = new ArrayList<PImage>();
  
  public ArrayList<PImage> cloudImgBank = new ArrayList<PImage>();
  public ArrayList<PImage> cloudImgs = new ArrayList<PImage>();
  public ArrayList<Integer> cloudTimer = new ArrayList<Integer>();
  public ArrayList<Integer> cloudPositionX = new ArrayList<Integer>();
  public ArrayList<Integer> cloudPositionY = new ArrayList<Integer>();
  public ArrayList<Integer> cloudSpeedX = new ArrayList<Integer>();
  public int timeUntilNextCloud = 0;
  
  public int timeUntilNextObstacle = 0;
  public int distancePerFrame = 60;
  public int distanceUntilNextFrame = distancePerFrame;
  
  // Jump. If the dino is not on the ground, then do nothing.
  public void jump(){
    if (dinoJump.yPos == dinoJump.ground - dinoJump.h/2) {
      yPos = ground - (h/2 + 1);
      yVel = -30;
      frameType = 1;
      frameNum = 0;
    }
  }
  
  // Move one lane to the left. If the dino is already on the left lane, then do nothing.
  public void moveLeft() {
    if (lane != 0)
      lane--;
  }
  
  // Move one lane to the right. If the dino is already on the right lane, then do nothing.
  public void moveRight() {
    if (lane != 2)
      lane++;
  }
  
  public void addObstacle(int lane, int pos) {
    obstacleLane.add(lane);
    obstaclePos.add(pos);
  }
  
  public void generateObstacle() {
    int pos = position - 10000; // obstacle is 10000px ahead of dino
    int progress = abs(position);
    int threeBlockChance = min(20 + progress / 6000, 50);
    int minPeriod = max(1000 - progress / 100, 1);
    int maxPeriod = max(3000 - progress / 150, 1000);
    if (random(100) < 12) {
      // generate an item
      int lane = (int) random(3);
      addItem(lane, pos, (int) random(2));
    } else {
      // generate an obstacle
      if (random(100) < threeBlockChance) {
        // 20% chance to have 1 obstacle on each lane
        for (int l = 0; l < 3; l++)
          addObstacle(l, pos);
      } else {
        int l = (int) random(3); // random int from 0 to 2
        addObstacle(l, pos);
      }
    }
    timeUntilNextObstacle = (int) random(minPeriod, maxPeriod);
  }
  
  public void removeObstacle(){
    for(int i=0;i < obstaclePos.size();i++){
      if (obstaclePos.get(i) > position){
        obstaclePos.remove(i);
        obstacleLane.remove(i);
      }
    }
  }
  
  public void addItem(int lane, int pos, int col) {
    itemLane.add(lane);
    itemPos.add(pos);
    itemtype.add(col);
  }
  
  public void removeItem(){
    for(int i=0;i < itemPos.size();i++){
      if (itemPos.get(i) > position){
        itemPos.remove(i);
        itemLane.remove(i);
        itemtype.remove(i);
      }
    }
  }
  
  public void checkCollision()
  {
     for(int i=0;i < obstaclePos.size();i++)
     {
       if(Math.abs(obstaclePos.get(i)-position)<=150 && Math.abs(lanes[obstacleLane.get(i)]-xPos)<=150 && Math.abs(yPos-(ground - h/2))<=150)
         
         if(shield==0)
         gameScreen=2;
         else
         {
           shield=0;
           obstaclePos.remove(i);
           obstacleLane.remove(i);
         }
     }
  }
  public void shielder()
  {
    if (shieldtimer!=0)
    {
      shieldsub-=18;
      shieldtimer=30+(shieldsub/1000);   
    }
    else
    shield=0;
  }

  public void checkItemCollision()
  {
     for(int i=0;i < itemPos.size();i++){
       if(Math.abs(itemPos.get(i)-position)<=150 && Math.abs(lanes[itemLane.get(i)]-xPos)<=150 && yPos == ground - h/2)
       {
        if(itemtype.get(i)== 0)
        gun=1;
        else if (itemtype.get(i)== 1)
        {
          shield =1;
          shieldtimer= 30;
          shieldsub=0;
        }
        // Remove item
        itemLane.remove(i);
        itemPos.remove(i);
        itemtype.remove(i);
       }
     }
  }
  
  public void generateCloud(){
    cloudImgs.add(cloudImgBank.get((int)(random(3))));
    cloudTimer.add(0);
    cloudPositionX.add((int)(random(2000)-1000));
    cloudPositionY.add((int)(random(1000)-500));
    int speed = 0;
    if ((int)random(2) == 1) speed = -1;
    else speed = 1;
    println(speed);
    cloudSpeedX.add(speed);
  }
  
  public void removeCloud(int k){
    cloudImgs.remove(k);
    cloudTimer.remove(k);
    cloudPositionX.remove(k);
    cloudPositionY.remove(k);
    cloudSpeedX.remove(k);
  }
    
  public void tick() {
    zVel = max(zVel, min(30, 10 + abs(position) / 10000));
    
    position -= zVel;
    distanceUntilNextFrame -= zVel;
    
    if (shield==1)
    shielder();
    
    checkCollision();
    if (yPos < ground - h/2){
      yPos += yVel;
      yVel += yAccel;
    }
    if (yPos > ground - h/2) {
      yPos = ground - h/2;
      frameType = 0;
      frameNum = 0;
    }
        
    if (xPos != lanes[lane]){
      if (Math.abs(xPos - lanes[lane]) < xVel){
        xPos = lanes[lane];
      }
      else{
      xPos -= xVel*(xPos-lanes[lane])/Math.abs(xPos-lanes[lane]);
      }
    }
    if (timeUntilNextObstacle <= 0) {
      generateObstacle();
      removeObstacle();
    }
    if (distanceUntilNextFrame <= 0){
      distanceUntilNextFrame = distancePerFrame;
      frameNum = (frameNum + 1)%frameNums[frameType];
      //zVel += 10; //for testing speedup
    }
    timeUntilNextObstacle -= zVel;
    if(timeUntilNextCloud == 0){
      generateCloud();
      timeUntilNextCloud = 2000;
    }
    timeUntilNextCloud--;
    checkItemCollision();
  }
 void shoot ()
  {
   if(gun==1)
    {
      for(int i=0;i < dinoJump.obstaclePos.size();i++)
       {
         if(obstacleLane.get(i)==lane && Math.abs(obstaclePos.get(i)-position)<=6000 && position>obstaclePos.get(i))
         {
           obstaclePos.remove(i);
           obstacleLane.remove(i);
           break;
         }
       }
      gun=0;
    }
  }
}



public void mousePressed(){
  if (gameScreen==0){
    startGame();
  }
  else if (gameScreen==2){
      restart();
  }

  else if (gameScreen==3){
    startGame();
  }
 else if (gameScreen==1)
 {
   dinoJump.shoot();
 }
  
  sound.play();
}
