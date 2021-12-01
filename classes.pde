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
  Actor(Vector[][] array, float xinit, float yinit) {
    xpos = xinit;
    ypos = yinit;
    //xpos = random(0,width);
    //ypos = random(0,height);
    vectors = array;
    xspeed = vectors[int(xpos)][int(ypos)].x;
    yspeed = vectors[int(xpos)][int(ypos)].y;
  }
  void update() {
    accelerate();
    move();
    point(xpos,ypos);
  }
  void accelerate() {
    if (int(xpos) >= pWidth) xpos = 0;
    if (int(xpos) < 0) xpos = pWidth-1;
    if (int(ypos) >= pHeight) ypos = 0;
    if (int(ypos) < 0) ypos = pHeight-1;
    float xvec = vectors[int(xpos)][int(ypos)].x;
    float yvec = vectors[int(xpos)][int(ypos)].y;
    xspeed = (1-vecImpact)*xspeed + vecImpact*xvec;
    yspeed = (1-vecImpact)*yspeed + vecImpact*yvec;
  }
  void move() {
    xpos += xspeed*10;
    ypos += yspeed*10;
  }
}
