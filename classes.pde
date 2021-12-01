class Vector {
  float x, y;
  Vector(int i,int j) {
    // divide by 100 makes the noise finer and the height/width offset gives them new values
    x = (noise((i/100)+width,(j/100)+height)-0.5)*speed;
    y = (noise((i/100),(j/100))-0.5)*speed;
  }
}

class Actor {
  float xpos, ypos, xspeed, yspeed;
  Vector[][] vectors;
  float[][] lives; 
  Actor(Vector[][] array, float xinit, float yinit) {
    //xpos = xinit;
    //ypos = yinit;
    xpos = random(0,width);
    ypos = random(0,height);
    vectors = array;
    xspeed = vectors[int(xpos)][int(ypos)].x;
    yspeed = vectors[int(xpos)][int(ypos)].y;
    lives = new float[defaultAge][2];
    lives[ageCounter % defaultAge][0] = xpos;
    lives[ageCounter % defaultAge][1] = ypos;
    
  }
  void update() {
    accelerate();
    move();
    display();
  }
  void accelerate() {
    float xvec = vectors[int(xpos)][int(ypos)].x;
    float yvec = vectors[int(xpos)][int(ypos)].y;
    xspeed = (1-vecImpact)*xspeed + vecImpact*xvec;
    yspeed = (1-vecImpact)*yspeed + vecImpact*yvec;
  }
  void move() {
    xpos = lives[(ageCounter - 1) % defaultAge][0] + xspeed*10;
    ypos = lives[(ageCounter - 1) % defaultAge][1] + yspeed*10;
    if (int(xpos) >= width) xpos = 0;
    if (int(xpos) < 0) xpos = width-1;
    if (int(ypos) >= height) ypos = 0;
    if (int(ypos) < 0) ypos = height-1;
    lives[ageCounter % defaultAge][0] = xpos;
    lives[ageCounter % defaultAge][1] = ypos;
    //xpos += xspeed*10;
    //ypos += yspeed*10;
  }
  
  void display() {
    int index = ageCounter % defaultAge;
    if (index + 1 < ageCounter) {
      int index2 = (index + 1) % defaultAge;
      float q = lives[index2][0];
      float w = lives[index2][1];
      strokeWeight(1);
      stroke(255);
      point(q,w);
    }
    float x = lives[index][0];
    float y = lives[index][1];
    strokeWeight(0.5);
    stroke(0);
    point(x,y);
  }
}

//class PointLoc {
//  int age;
//  int[] loc;
//  PointLoc(int a, int x, int y) {
//    loc = new int[2];
//    loc[0] = x;
//    loc[1] = y;
//    age = 0;
