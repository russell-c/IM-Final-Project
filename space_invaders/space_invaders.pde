import processing.video.*;

class Rect {  //constructing a class for the player and obstacle objects
  int x;
  int y;
  int w;
  int h;
  int[] rgb = new int[3];
  int velocity;
  int count;
  PImage[] img = new PImage[2];
  int i = 0;

  Rect(int x, int y, int w, int h, int r, int g, int b) { //specific constructor, mainly used to specify the player's object attributes
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.rgb[0] = r;
    this.rgb[1] = g;
    this.rgb[2] = b;
    this.velocity = 2;
    this.count = 0;
  }

  Rect() { //generic construction, assigns random values to each attribute, used for obstacle objects
    this.y = 0;
    this.x = (int)random(50, 400);
    this.w = 10;
    this.h = 10;
    this.rgb[0] = 255;
    this.rgb[1] = 0;
    this.rgb[2] = 0;
    this.velocity = (int)random(1, 3);
    this.count = 0;
  }

  void move(boolean isBullet) { //generic move that updates the y attribute, used for obstacle objects, note: y pos is constant
    if(isBullet){
      y -= velocity;
    } else {
      y += velocity;
    }
    
    count++; //each update to position increments count
  }

  void move(int moveX, int moveY) { //function that specifies where exactly the object should go on screen, used for player's object
    x = moveX;
    y = moveY;
  }

  boolean collideRect(Rect other) {
    if (this.x+this.w >= other.x && this.x+this.w <= other.x+other.w) { //if inside the obstacle bounds coming from the left side
      if (this.y <= other.y+other.h && this.y >= other.y) { //if inside the obstacle bounds coming from the bottom
        return true;
      }
      if (this.y+this.h >= other.y && this.y+this.h <= other.y+other.h) { //if inside the obstacle bounds coming from the top
        return true;
      }
    }

    if (this.x <= other.x+other.w && this.x >= other.x) { //if inside the obstacle bound coming from the right side
      if (this.y <= other.y+other.h && this.y >= other.y) { //if inside the obstacle bounds coming from the bottom
        return true;
      }
      if (this.y+this.h >= other.y && this.y+this.h <= other.y+other.h) { //if inside the obstacle bounds coming from the top
        return true;
      }
    }

    return false;
  }

  void drawRect() { //draw the object to the screen
    fill(rgb[0], rgb[1], rgb[2]);
    rect(x, y, w, h);
    count++;
  }
  
  void drawImg(){
    image(this.img[this.i], x-10, y-10, 30, 30); //draw specified image to screen
  }
}

ArrayList<Rect> obstacles = new ArrayList<Rect>();
ArrayList<Rect> bullets = new ArrayList<Rect>();
Rect player = new Rect(width/2, height, 20, 20, 0, 0, 0);
Rect temp, tempBullet;
boolean gameOver = false, alreadyShot;
int x, y, score = -1;
color trackColour;
Capture cam;
void setup(){
  size(640, 480);
  cam = new Capture(this, width, height);
  cam.start();
  background(255);
  obstacles.add(new Rect());
  trackColour = color(255, 255, 255);
}

void captureEvent(Capture cam){
  cam.read();
}

void draw() {
  cam.loadPixels();
  background(255);
  
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
    player.move(width-closestX,closestY); //move the player, the image is mirrored so flip the x value in which the player rect moves
    player.drawRect(); //display the player
  }
  
  if(score==-1){score=0;}
  
  if(obstacles.isEmpty()){
    obstacles.add(new Rect());
  }
  for (int i = 0; i<obstacles.size(); i++) { //loop through list of obstacles
    temp = obstacles.get(i);
    temp.move(false); //move obstacle

    if (temp.collideRect(player)) { //check for collision with player
      gameOver = true;
    }
    
    if(!bullets.isEmpty()){
      for(int c = 0; c<bullets.size(); c++){
        tempBullet = bullets.get(c);
        if(temp.collideRect(tempBullet)){
          bullets.remove(tempBullet);
          obstacles.remove(temp);
          score++;
        }
      }
    }

    if (temp.count==45) { //if count reaches this value (i.e. has been on screen for 45 frames) add a new obstacle
      obstacles.add(new Rect());
    }

    if (temp.y>height) { //if obstacle is off screen remove it from obstacle list
      obstacles.remove(i);
    }
    temp.drawRect(); //draw the obstacle
  }
  
  
  if(mousePressed){
    if(alreadyShot == false){
      bullets.add(new Rect(width-closestX, closestY, 5, 5, 0, 0, 0));
      alreadyShot = true;
    }
  }  
  
  if(!bullets.isEmpty()){
    for(int i=0; i<bullets.size(); i++){
      tempBullet = bullets.get(i);
      tempBullet.move(true);
      tempBullet.drawRect();
      
      if(tempBullet.y<0){
        bullets.remove(tempBullet);
      }
    }
  }
  
  fill(0);
  textSize(16);
  text("Score: ", 0, 15); //display score in top left
  text(score, 48, 15);
  
  
  if(gameOver == true){ //if a collision happened
    obstacles.clear(); //clear obstacle list entirely
    bullets.clear();
    background(255);
    fill(0);
    textSize(26);
    text("Game Over", 190, 240); //signifiers
    
    textSize(16);
    text("Score: ", 230, 265);
    text(score, 278, 265);
    
    text("Push enter button to play again!", 135, 400); //signifiers everywhere
   
  }
}

void keyPressed(){
  if(keyCode == ENTER || keyCode == RETURN){
      score = 0; //reset score
      obstacles.add(new Rect()); //reinitialise obstacles list
      gameOver = false;
   }
}

void mouseReleased(){
  alreadyShot = false;
}