class SurfaceObject extends TuiObject
{
  int deg;
  int[] blue = {0, 0, 255};
  int[] red = {255, 0, 0};
  int[] green = {0, 255, 0};
  int[] orange = {255, 128, 0};
  int[] purple = {128, 0, 128};

  SurfaceObject(int s_id,int f_id) 
  {
    super(s_id, f_id);
  }

  void update(int x, int y, float a) 
  {
    super.update(x, y, a);
    deg = (int)(angle*180/PI);
  }

  void draw() 
  {
    fill(blue[0], blue[1], blue[2]);
    pushMatrix();
    translate(xpos, ypos);
    rotate(deg);
    float ang = 360.0 / 8;
    beginShape();
    for (int i = 0; i < 8; i++) {
      vertex(80/2 * cos(radians(ang * i)), 80/2 * sin(radians(ang * i)));
    }
    endShape(CLOSE);

    noStroke();

    popMatrix();

    fill(255);
    text(fiducial_id + " : " + deg + "\nX:" + xpos + "\nY:"+ypos, xpos - 20, ypos - 20);
  }

}
