import processing.serial.*;
import processing.video.*;
import processing.sound.*;

class Rect {  //constructing a class for the player and obstacle objects
  int x;
  int y;
  int w;
  int h;
  int velocity;
  int count;
  PImage img;
  boolean imgSet = false;


  Rect() { //generic construction, assigns random values to each attribute, used for obstacle objects
    this.y = 0;
    this.x = (int)random(0, width);
    this.w = (int)random(10,20);
    this.h = w;
    this.velocity = (int)random(1, 3);
    this.count = 0;
  }

  void move() { //generic move that updates the y attribute, used for obstacle objects, note: y pos is constant
    y += velocity;
    count++; //each update to position increments count
  }

  boolean collideRect(Rect other) {
    if ( ((other.x + other.w) >= this.x) && (other.x <= (this.x+this.w)) && ( (other.y + other.h) >= this.y) && (other.y <= (this.y+this.h)) ) {
      return true;
    }
    return false;
  }

  void drawRect() { //draw the object to the screen
    rect(x, y, w, h);
    count++;
  }

  void setImage(PImage img){
    this.img = img;
    this.imgSet = true;
  }

  void drawImg() {
    if(this.imgSet){
      image(this.img, this.x-10, this.y-15, w, h); //draw specified image to screen
    } else {
      print("The image for this object is not set");
    }
  }
}

class StellarObject extends Rect {
  
  int damageTaken;
  int frame = 0;
  int imageIndex = 0;
  PImage[] imageArr;
  Rect hitBox;
  
  StellarObject(int w, int h, int x, int y, int arrSize, int type){
    damageTaken = 0;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    imageArr = new PImage[arrSize];
    hitBox = new Rect();
   
    if(type == 0){
      hitBox.y = y+50;
      hitBox.h = h-50;
      hitBox.w = w-40;
      hitBox.x = x+20;
    } else if(type == 1){
      hitBox.h = h;
      hitBox.y = y;
      hitBox.w = w;
      hitBox.x = x;
    }
    
  }
  
  void drawImages(){
    if(this.imgSet){
      image(this.imageArr[imageIndex],this.x,this.y,this.w,this.h);
      if(frame>=15){
        imageIndex = (imageIndex+1)%imageArr.length;
        frame = 0;
      }
      frame++;
    } else {
      print("Earth object image is not set");
    }
  }
  
  void setImages(PImage[] images){
    for(int i =0;i<imageArr.length;i++){
      this.imageArr[i] = images[i];
    }
    this.imgSet = true;
  }
  
  void takeDamage(int damage){
    this.damageTaken += damage;
  }
}


class Asteroid extends Rect {
  
  int damage = 0;
  
  Asteroid(){
    damage = (int)(w*0.75);
  }
  
  void drawImg(){
    if(this.imgSet){
      image(this.img, x-20, y-15, w+20, h+10); //draw specified image to screen
    } else {
      print("The image for this object is not set");
    }
  }
}

class Player extends Rect {

  Player(int x, int y, int w, int h) { //specific constructor, mainly used to specify the player's object attributes
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.velocity = 2;
    this.count = 0;
  }

  void move(int moveX, int moveY) { //function that specifies where exactly the object should go on screen, used for player's object
    x = moveX;
    y = moveY;
  }
}

class Bullet extends Rect {

  Bullet(int x, int y) { //specific constructor, mainly used to specify the player's object attributes
    this.x = x;
    this.y = y;
    this.w = 25;
    this.h = 25;
    this.velocity = 2;
    this.count = 0;
  }

  void move() { //generic move that updates the y attribute, used for obstacle objects, note: y pos is constant
    y -= velocity;
    count++; //each update to position increments count
  }
}

class Explosion {
  int x = 0, y = 0, w = 40, h = 40, frame = 0, explosionIndex = 0;
  PImage[] explosionSet = new PImage[8];
  boolean shouldAnimate = false;
  SoundFile explode;

  Explosion(int x, int y) {
    this.x = x;
    this.y = y;
  }

  void addImages(PImage[] images) {
    for (int i = 0; i<this.explosionSet.length; i++) {
      this.explosionSet[i] = images[i];
    }
  }

  void startAnimating() { 
    explode.play();
    this.addImages(explosionArr); //add the image assets to the explosion so that it can animate
    this.shouldAnimate = true;
  }

  void endAnimating() {
    this.shouldAnimate = false;
    this.explosionIndex = 0;
    this.frame = 0;
  }
  
  void animate(){
    if(shouldAnimate){
      if((frame%3)==0){ //every 2 frames in processing draw a new frame of the explosion gif
        image(this.explosionSet[explosionIndex],this.x,this.y,w,h);
        explosionIndex++;
      }
      frame++;
      if (this.explosionIndex>=this.explosionSet.length) {
        this.endAnimating();
      }
    }
  }
}

class LargeAsteroid extends Asteroid {
  int hitsTaken = 0;
  boolean shouldExplode = false;
  
  LargeAsteroid(){
    this.velocity = 1;
    this.w = 60;
    this.h = 60;
    this.damage = (int)(0.67*this.w);
  }
  
  void takeHit(){
    this.hitsTaken++;
    if(this.hitsTaken >= 3){
      this.shouldExplode = true;
    }
  }
}

ArrayList<Asteroid> obstacles = new ArrayList<Asteroid>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Bullet> bigBullets = new ArrayList<Bullet>();
ArrayList<Explosion> explosions = new ArrayList<Explosion>();
ArrayList<LargeAsteroid> largeAsteroids = new ArrayList<LargeAsteroid>();
Player player = new Player(width/2, height, 35, 35);
Asteroid temp; 
Bullet tempBullet;
Explosion tempExplosion;
LargeAsteroid tempLargeAsteroid;
StellarObject earth = new StellarObject(320,263,75, 333, 40, 0);
StellarObject moon = new StellarObject(80,80,width/2+375, 253, 25, 1);

boolean gameOver = false, alreadyShot, showWarning = false, drawMoon = false, newHigh = false, textDisplaying = false, makeLargeAsteroid = false;
int x, y, score = -1, currentDiff, highScore = -1, bigNiggaCounter = 0, largeAsteroidFrameCount = -1;
int[] difficulty = {50, 35, 25}, warningCounter = {0, 0};
color trackColour;
PImage spaceshipImg, bulletImg, bigBulletImg, largeAsteroidImg;
PImage[] earthImages = new PImage[40], moonImages = new PImage[25];
PImage[] bgArr = new PImage[5];
PImage[] asteroidArr = new PImage[4];
PImage[] explosionArr = new PImage[8];
PFont font; 
color dangerColor = color(242,33,40), healthyColor = color(39,216,77), achievementColor = color(255, 255, 0);
color earthBarColor = healthyColor, moonBarColor = healthyColor;
float healthBarWidth = 200, tooMuchDamageTaken = 100;
float earthHealth = 0, moonHealth = 0;
int bg = 0, bgCount = 0;
int[] levelCount = {0, 0, 0};
SoundFile explosionSound, bgMusic, laser;
Table highScoreTable;
Capture cam;
Serial port;

void setup() {
  size(640, 480);
  port = new Serial(this, Serial.list()[5], 9600);
  port.bufferUntil('\n');
  cam = new Capture(this, width, height);
  cam.start();
  background(255);
  obstacles.add(new Asteroid());
  trackColour = color(255, 255, 255);
   
  bulletImg = loadImage("missile.png");
  bigBulletImg = loadImage("largemissile.png");
  largeAsteroidImg = loadImage("largeAsteroid.png");
  
  spaceshipImg = loadImage("xwing.png"); //load the spaceship image
  player.setImage(spaceshipImg); //attach it to the player object 
 
  String imageName;

  for(int i=0;i<earth.imageArr.length;i++){
    imageName = "rotating_earth_"+nf(i,2)+"_delay-0.3s.png";
    earthImages[i] = loadImage(imageName);
  }
  
  earth.setImages(earthImages);
  
  for(int i=0;i<moon.imageArr.length;i++){
    imageName = "rotating_moon_"+nf(i,2)+"_delay-0.04s.gif";
    moonImages[i] = loadImage(imageName);
  }
  
  moon.setImages(moonImages);
  
  for (int i = 0; i < 5; i++) {
    imageName = "background_" + nf(i, 1) + "_delay-0.25s.gif";
    bgArr[i] = loadImage(imageName);
  }

  for (int i = 0; i < 4; i++) {
    imageName = "asteroid"+nf(i+1,1)+".png";
    asteroidArr[i] = loadImage(imageName);
  }

  for (int i = 0; i<explosionArr.length; i++) {
    imageName = "explosion_"+nf(i, 1)+"_delay-0.1s.png";
    explosionArr[i] = loadImage(imageName);
  }
  
  explosionSound = new SoundFile(this, "boom.wav");
  explosionSound.rate(0.5);
  
  bgMusic = new SoundFile(this, "bgSong.wav");
  bgMusic.amp(0.5); //sets the volume, accepts values between 0 and 1
  bgMusic.rate(0.95);
  bgMusic.loop();
  
  laser = new SoundFile(this, "laser.wav");
  font = loadFont("HelveticaNeue-48.vlw");
  
  //save to CSV table that keeps the highscore
  highScoreTable = loadTable("highscore.csv","header");
  for(TableRow row : highScoreTable.rows()){
    highScore = row.getInt("highscore");
  }
  
}

void captureEvent(Capture cam) {
  cam.read();
}

boolean setGreeting = true;
TableRow newRow;
void draw() {
  
  background(bgArr[bg]);
  bgCount++;
  if (bgCount>=10) {
    bg = (bg+1)%5;
    bgCount=0;
  }
  
  if(!gameOver){
    newRow = highScoreTable.addRow();
    cam.loadPixels();
    
    
    if (score==-1) {
      score=0;
    }
    
    if(highScore < score){
      highScore = score;
      newRow.setInt("highscore",highScore);
      saveTable(highScoreTable,"data/highscore.csv");
      newHigh = true;
    }
    
    earthHealth = ((tooMuchDamageTaken - earth.damageTaken)/100) * healthBarWidth;
    if(drawMoon){
      moonHealth = ((tooMuchDamageTaken - moon.damageTaken)/100) * healthBarWidth;
      fill(255);
      textFont(font, 15);
      text("Moon's Health: ",width-(healthBarWidth+130),82);
      fill(52,52,52);
      rect(width-(healthBarWidth+20),60,healthBarWidth,30);
      fill(moonBarColor);
      rect(width-(healthBarWidth+20),60,moonHealth,30);
      fill(255);
      textFont(font, 15);
      text("Score: ", width-(healthBarWidth+130), 100); //display score in top left
      textFont(font, 15);
      text(score, width-(healthBarWidth+80), 100);
      textFont(font, 15);
      text("High Score: ", width-(healthBarWidth+130), 118); //display score in top left
      textFont(font, 15);
      if(newHigh){
        fill(achievementColor);
      }
      text(highScore, width-(healthBarWidth+45), 118);
      fill(255);
    } else {
      fill(255);
      textFont(font, 15);
      text("Score: ", width-(healthBarWidth+130), 60); //display score in top left
      textFont(font, 15);
      text(score, width-(healthBarWidth+80), 60);
      textFont(font, 15);
      text("High Score: ", width-(healthBarWidth+130), 78); //display score in top left
      textFont(font, 15);
      if(newHigh){
        fill(achievementColor);
      }
      text(highScore, width-(healthBarWidth+45), 78);
      fill(255);
    }
    
    fill(255);
    textFont(font, 15);
    text("Earth's Health: ",width-(healthBarWidth+130),42);
    fill(52,52,52);
    rect(width-(healthBarWidth+20),20,healthBarWidth,30);
    fill(earthBarColor);
    rect(width-(healthBarWidth+20),20,earthHealth,30);
    
    
    if(showWarning){
        
      if(moon.damageTaken >= 50 && warningCounter[0]<=100){
        fill(255);
        textFont(font, 20);
        text("Oh no! The Moon is in danger! Save it!", width/2-150,height/2);
        warningCounter[0]++;
        if(warningCounter[0] == 150){ 
          showWarning = false; 
        }
      } else if(earth.damageTaken >= 50 && warningCounter[1]<=100) {
        fill(255);
        textFont(font, 20);
        text("Oh no! The Earth is in danger! Save it!", width/2-150,height/2);
        warningCounter[1]++;
        if(warningCounter[1] == 150){ 
          showWarning = false; 
        }
      }
    } 
    
    earth.drawImages();
  
    if (score<30) {
      if(levelCount[0] < 180){
        levelCount[0]++;
        fill(achievementColor);
        textFont(font, 20);
        text("Level 1: Protect the Earth! Save the Dinosaurs!", width/2-190,height/2);
        fill(255);
        obstacles.clear();
        textDisplaying = true;
      } else {
        textDisplaying = false;
      }
      currentDiff = difficulty[0];
    } else if (score>=30 && score <= 60) {
      if(levelCount[1] < 180){
        levelCount[1]++;
        fill(achievementColor);
        textFont(font, 20);
        text("Level 2: The Moon is under threat! You know what to do!", width/2-240,height/2);
        fill(255);
        obstacles.clear();
        textDisplaying = true;
      } else {
        textDisplaying = false;
      }
      currentDiff = difficulty[1];
      bgMusic.rate(1);
      drawMoon = true;
    } else if (score>60) {
      if(levelCount[2] < 180){
        levelCount[2]++;
        fill(achievementColor);
        textFont(font, 20);
        text("Level 3: Now entering Chaos Mode!", width/2-150,height/2);
        fill(255);
        obstacles.clear();
        largeAsteroids.clear();
        textDisplaying = true;
      } else {
        textDisplaying = false;
      }
      bgMusic.rate(1.05);
      currentDiff = difficulty[2];
      if(largeAsteroidFrameCount == -1){
        makeLargeAsteroid = true;
      }
      
    }
    
    if(drawMoon){
      moon.drawImages();
    }
  
    float worldRecord = 500; 
  
    // XY coordinate of closest color
    int closestX = 0;
    int closestY = 0;
  
    // Begin loop to walk through every pixel
    for (int x = 0; x < cam.width; x ++ ) {
      for (int y = 0; y < cam.height; y ++ ) {
        int loc = x + y*cam.width;
        // What is current color
        color currentColor = cam.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
        float r2 = red(trackColour);
        float g2 = green(trackColour);
        float b2 = blue(trackColour);
  
        // Using euclidean distance to compare colors
        float d = dist(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.
  
        // If current color is more similar to tracked color than
        // closest color, save current location and current difference
        if (d < worldRecord) {
          worldRecord = d;
          closestX = x;
          closestY = y;
        }
      }
    }
  
    // We only consider the color found if its color distance is less than 10. 
    // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
    if (worldRecord < 10) { 
      player.move(width-closestX,closestY); //move the player, the image is mirrored so flip the x value in which the player rect moves
    }
    
    //UNCOMMENT IF BUTTON BREAKS
    //player.move(mouseX,mouseY);
    
    player.drawImg();
  
  
    if (obstacles.isEmpty() && !textDisplaying) {
      obstacles.add(new Asteroid());
    }
    
    if(makeLargeAsteroid){
      largeAsteroidFrameCount++;
      if(largeAsteroidFrameCount >= 400){
        tempLargeAsteroid = new LargeAsteroid();
        tempLargeAsteroid.setImage(largeAsteroidImg);
        largeAsteroids.add(tempLargeAsteroid);
        largeAsteroidFrameCount = 0;
        makeLargeAsteroid = true;
      }
    }
    
    for(int i=0;i<largeAsteroids.size();i++){
      tempLargeAsteroid = largeAsteroids.get(i);
      if(!tempLargeAsteroid.imgSet){
        temp.setImage(largeAsteroidImg);
      }
      
      tempLargeAsteroid.move();
      if (tempLargeAsteroid.collideRect(player) || earth.damageTaken >= 100 || moon.damageTaken >= 100) { //check for collision with player
        tempExplosion = new Explosion(player.x, player.y);
        tempExplosion.explode = explosionSound;
        tempExplosion.startAnimating();
        explosions.add(tempExplosion);
        gameOver = true;
      }
      for(int j = 0;j<bullets.size();j++){
        tempBullet = bullets.get(j);
        if(tempLargeAsteroid.collideRect(tempBullet)){
          tempLargeAsteroid.takeHit();
          tempExplosion = new Explosion(tempBullet.x, tempBullet.y);
          tempExplosion.h = tempExplosion.w = 20;
          tempExplosion.explode = explosionSound;
          tempExplosion.startAnimating();
          score++;
          explosions.add(tempExplosion);
          if(tempLargeAsteroid.shouldExplode){
            tempExplosion = new Explosion(tempBullet.x, tempBullet.y);
            tempExplosion.h = tempExplosion.w = 50;
            tempExplosion.explode = explosionSound;
            tempExplosion.startAnimating();
            explosions.add(tempExplosion);
            largeAsteroids.remove(tempLargeAsteroid);
            score+=2;
          }
          bullets.remove(tempBullet);
        }
      }
      
      for(int h = 0;h<bigBullets.size();h++){
        tempBullet = bigBullets.get(h);
        if(tempLargeAsteroid.collideRect(tempBullet)){
          tempExplosion = new Explosion(tempBullet.x, tempBullet.y);
          tempExplosion.h = tempExplosion.w = 50;
          tempExplosion.explode = explosionSound;
          tempExplosion.startAnimating();
          explosions.add(tempExplosion);
          largeAsteroids.remove(tempLargeAsteroid);
          bigBullets.remove(tempBullet);
        }
       }
       
       if(tempLargeAsteroid.collideRect(earth.hitBox)){
          earth.takeDamage(tempLargeAsteroid.damage);
          tempExplosion = new Explosion(temp.x-10,temp.y-10);
          tempExplosion.explode = explosionSound;
          tempExplosion.startAnimating();
          explosions.add(tempExplosion);
          largeAsteroids.remove(tempLargeAsteroid);
       }
      
       if(tempLargeAsteroid.collideRect(moon.hitBox) && drawMoon){
          moon.takeDamage((int)(tempLargeAsteroid.damage));
          tempExplosion = new Explosion(temp.x-10,temp.y-10);
          tempExplosion.explode = explosionSound;
          tempExplosion.startAnimating();
          explosions.add(tempExplosion);
          largeAsteroids.remove(tempLargeAsteroid);
       } 
       tempLargeAsteroid.drawImg();
       if(tempLargeAsteroid.y > height){
         largeAsteroids.remove(tempLargeAsteroid);
       }
    }
    
    for (int i = 0; i<obstacles.size(); i++) { //loop through list of obstacles
      temp = obstacles.get(i);
      if (temp.imgSet == false) {
        temp.setImage(asteroidArr[(int) random(0, 4)]);
      }
      temp.move(); //move obstacle
  
      if (temp.collideRect(player) || earth.damageTaken >= 100 || moon.damageTaken >= 100) { //check for collision with player
        tempExplosion = new Explosion(player.x, player.y);
        tempExplosion.explode = explosionSound;
        tempExplosion.startAnimating();
        explosions.add(tempExplosion);
        gameOver = true;
      }
      
      if (!bullets.isEmpty()) {
        for (int c = 0; c<bullets.size(); c++) {
          tempBullet = bullets.get(c);
          if (temp.collideRect(tempBullet)) {
            //create a new explosion object for each collision that occurs
            tempExplosion = new Explosion(temp.x-10, temp.y-10); //create the explosion at the point the bullet hits the object
            tempExplosion.explode = explosionSound;
            tempExplosion.startAnimating(); //set the shouldAnimate property of the explosion to true so that it can start animating afterwards
            explosions.add(tempExplosion); //add each explosion to a list, they will be animated later
            bullets.remove(tempBullet);
            obstacles.remove(temp);
            score++;
            if(score>60){
              bigNiggaCounter++;
            }
          }
        }
      }
      
      if (!bigBullets.isEmpty()) {
        for (int c = 0; c<bigBullets.size(); c++) {
          tempBullet = bigBullets.get(c);
          if (temp.collideRect(tempBullet)) {
            //create a new explosion object for each collision that occurs
            tempExplosion = new Explosion(temp.x-10, temp.y-10); //create the explosion at the point the bullet hits the object
            tempExplosion.explode = explosionSound;
            tempExplosion.startAnimating(); //set the shouldAnimate property of the explosion to true so that it can start animating afterwards
            explosions.add(tempExplosion); //add each explosion to a list, they will be animated later
            obstacles.remove(temp);
            score++;
          }
        }
      }
      
      if(temp.collideRect(earth.hitBox)){
        earth.takeDamage(temp.damage);
        tempExplosion = new Explosion(temp.x-10,temp.y-10);
        tempExplosion.explode = explosionSound;
        tempExplosion.startAnimating();
        explosions.add(tempExplosion);
        obstacles.remove(temp);
      }
      
      if(temp.collideRect(moon.hitBox) && drawMoon){
        moon.takeDamage((int)(temp.damage*1.5));
        tempExplosion = new Explosion(temp.x-10,temp.y-10);
        tempExplosion.explode = explosionSound;
        tempExplosion.startAnimating();
        explosions.add(tempExplosion);
        obstacles.remove(temp);
      }
      
  
      if (temp.count==currentDiff) { //if count reaches this value (i.e. has been on screen for 45 frames) add a new obstacle
        obstacles.add(new Asteroid());
      }
  
      if (temp.y>height) { //if obstacle is off screen remove it from obstacle list
        obstacles.remove(i);
      }
      temp.drawImg(); //draw the obstacle
    }
    
    if(earth.damageTaken >= 50){
        earthBarColor = dangerColor;
        showWarning = true;
    }
    
    if(moon.damageTaken >= 50){
        moonBarColor = dangerColor;
        showWarning = true;
    }
  
    //animate all the explosions that were added to the explosions list
    for (int i=0; i<explosions.size(); i++) {
      tempExplosion = explosions.get(i);
      tempExplosion.animate();
    }
    
    if(bigNiggaCounter >= 5){
      tempBullet = new Bullet(mouseX, mouseY-25);
      tempBullet.setImage(bigBulletImg);
      tempBullet.h = 50;
      tempBullet.w = 50;
      tempBullet.velocity = 3;
      bigBullets.add(tempBullet);
      bigNiggaCounter = 0;
    }
    
    //UNCOMMENT IF BUTTON BREAKS
    //if (mousePressed) {
    //  if (alreadyShot == false) {
    //    // UNCOMMENT FOR PRODUCTION
    //    //bullets.add(new Bullet(width-closestX, closestY-25));
  
    //    //TESTING
    //    bullets.add(new Bullet(player.x, player.y-25));
    //    laser.play();
    //    alreadyShot = true;
    //  }
    //}  
  
    if (!bullets.isEmpty()) {
      for (int i=0; i<bullets.size(); i++) {
        tempBullet = bullets.get(i);
        tempBullet.setImage(bulletImg);
        tempBullet.move();
        tempBullet.drawImg();
  
        if (tempBullet.y<0) {
          bullets.remove(tempBullet);
        }
      }
    }
    
    if (!bigBullets.isEmpty()){
      for(int i = 0; i < bigBullets.size(); i++){
        tempBullet = bigBullets.get(i);
        tempBullet.move();
        tempBullet.drawImg();
        
        if (tempBullet.y<0) {
          bullets.remove(tempBullet);
        }
      }
    }
  }
  if (gameOver == true) { //if a collision happened
    bgMusic.rate(0.95);
    levelCount[0] = 0;
    levelCount[1] = 0;
    levelCount[2] = 0;
    largeAsteroidFrameCount = -1;
    drawMoon = false;
    earthBarColor = healthyColor;
    moonBarColor = healthyColor;
    warningCounter[0] = 0;
    warningCounter[1] = 0;
    bigNiggaCounter = 0;
    earth.damageTaken = 0;
    moon.damageTaken = 0;
    obstacles.clear(); //clear obstacle list entirely
    bullets.clear();
    explosions.clear();
    bigBullets.clear();
    largeAsteroids.clear();
    background(bgArr[bg]);
    fill(255);
    textFont(font, 26);
    fill(dangerColor);
    text("Game Over!", width/2-80, height/2-25); //signifiers
    fill(255);
    textFont(font, 15);
    text("Score: ", width/2-40, height/2);
    fill(healthyColor);
    text(score, width/2+10, height/2);
    fill(255);
    textFont(font, 15);
    text("High Score: ", width/2-60, height/2+18);
    fill(healthyColor);
    text(highScore, width/2+25, height/2+18);
    fill(255);
    
    if(newHigh){
      fill(achievementColor);
      text("NEW HIGH SCORE!!", width/2-75, height/2+46);
      fill(255);
    }
    
    text("Push ", width/2-120, height/2+76); 
    fill(healthyColor);
    text("ENTER ",width/2-80, height/2+76);
    fill(255);
    text("button to play again!", width/2-25, height/2+76); //signifiers everywhere
  }
}

void keyPressed() {
  if (keyCode == ENTER || keyCode == RETURN) {
    score = 0; //reset score
    obstacles.add(new Asteroid()); //reinitialise obstacles list
    gameOver = false;
    newHigh = false;
  }
}

void mouseReleased() {
  alreadyShot = false;
}

void serialEvent (Serial port){
  String inByte = port.readStringUntil('\n');
  inByte = trim(inByte);
  if(inByte.equals("1")){
    if(!gameOver){
      bullets.add(new Bullet(player.x, player.y-25));
      laser.play();
    } else {
      score = 0; //reset score
      obstacles.add(new Asteroid()); //reinitialise obstacles list
      gameOver = false;
      newHigh = false;
    }
  }
}