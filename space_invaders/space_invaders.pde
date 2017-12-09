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
  int x = 0, y = 0, frame = 0, explosionIndex = 0;
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
        image(this.explosionSet[explosionIndex],this.x,this.y,40,40);
        explosionIndex++;
      }
      frame++;
      if (this.explosionIndex>=this.explosionSet.length) {
        this.endAnimating();
      }
    }
  }
}

ArrayList<Asteroid> obstacles = new ArrayList<Asteroid>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Explosion> explosions = new ArrayList<Explosion>();
Player player = new Player(width/2, height, 35, 35);
Asteroid temp; 
Bullet tempBullet;
Explosion tempExplosion;
StellarObject earth = new StellarObject(320,263,75, 333, 40, 0);
StellarObject moon = new StellarObject(80,80,width/2+375, 253, 25, 1);

boolean gameOver = false, alreadyShot, showWarning = false, drawMoon = false, newHigh = false;
int x, y, score = -1, currentDiff, warningCounter = 0, highScore = 0;
int[] difficulty = {45, 30, 15};
color trackColour;
PImage spaceshipImg, bulletImg;
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
SoundFile explosionSound, bgMusic, laser;
Capture cam;

void setup() {
  size(640, 480);
  cam = new Capture(this, width, height);
  cam.start();
  background(255);
  obstacles.add(new Asteroid());
  trackColour = color(255, 255, 255);
   
  bulletImg = loadImage("missile.png");
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
  bgMusic.loop();
  
  laser = new SoundFile(this, "laser.wav");
  font = loadFont("HelveticaNeue-48.vlw");
}

void captureEvent(Capture cam) {
  cam.read();
}

void draw() {
  
  cam.loadPixels();
  background(bgArr[bg]);
  bgCount++;
  if (bgCount>=10) {
    bg = (bg+1)%5;
    bgCount=0;
  }
  
  if (score==-1) {
    score=0;
  }
  
  if(highScore < score){
    highScore = score;
    newHigh = true;
  }
  
  earthHealth = ((tooMuchDamageTaken - earth.damageTaken)/100) * healthBarWidth;
  moonHealth = ((tooMuchDamageTaken - moon.damageTaken)/100) * healthBarWidth;
  
  fill(255);
  textFont(font, 15);
  text("Earth's Health: ",width-(healthBarWidth+130),42);
  fill(52,52,52);
  rect(width-(healthBarWidth+20),20,healthBarWidth,30);
  fill(earthBarColor);
  rect(width-(healthBarWidth+20),20,earthHealth,30);
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
  
  if(showWarning && warningCounter < 100){
      
    if(moon.damageTaken >= 50){
      fill(255);
      textFont(font, 20);
      text("Oh no! The Moon is in danger! Save it!", width/2-150,height/2);
    } else if(earth.damageTaken >= 50) {
      fill(255);
      textFont(font, 20);
      text("Oh no! The Earth is in danger! Save it!", width/2-150,height/2);
    }
    
    warningCounter++;
    if(warningCounter >= 100){ 
      showWarning = false; 
    }
  } else if(showWarning == false){
    warningCounter = 0;
  }
  
  earth.drawImages();

  if (score<60) {
    currentDiff = difficulty[0];
    drawMoon = true;
  } else if (score>60 && score < 120) {
    currentDiff = difficulty[1];
    drawMoon = true;
  } else if (score>120) {
    currentDiff = difficulty[2];
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
    // Draw a circle at the tracked pixel

    //UNCOMMENT FOR ACTUAL PROJECT
    //player.move(width-closestX,closestY); //move the player, the image is mirrored so flip the x value in which the player rect moves
  }
  
  //FOR TESTING
    player.move(mouseX, mouseY);
    //player.drawRect(); //display the player
    player.drawImg();


  if (obstacles.isEmpty()) {
    obstacles.add(new Asteroid());
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

  if (mousePressed) {
    if (alreadyShot == false) {
      // UNCOMMENT FOR PRODUCTION
      //bullets.add(new Bullet(width-closestX, closestY-25));

      //TESTING
      bullets.add(new Bullet(mouseX, mouseY-25));
      laser.play();
      alreadyShot = true;
    }
  }  

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


  if (gameOver == true) { //if a collision happened
    drawMoon = false;
    earthBarColor = healthyColor;
    moonBarColor = healthyColor;
    warningCounter = 0;
    earth.damageTaken = 0;
    moon.damageTaken = 0;
    obstacles.clear(); //clear obstacle list entirely
    bullets.clear();
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