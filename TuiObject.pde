/*
        TUIO processing demo - part of the reacTIVision project
 http://mtg.upf.es/reactable
 
 Copyright (c) 2006 Martin Kaltenbrunner <mkalten@iua.upf.es>
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files
 (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software,
 and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 Any person wishing to distribute modifications to the Software is
 requested to send the modifications to the original developer so that
 they can be incorporated into the canonical version.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

public class TuiObject {
  int session_id, fiducial_id;
  int xpos, ypos;
  float angle;

  TuiObject(int s_id,int f_id) {
    session_id  = s_id;
    fiducial_id = f_id; 
    xpos = 0; 
    ypos = 0; 
    angle = 0.0f;
    rectMode(CENTER);
  }

  void update(int x, int y, float a) {
    xpos=x;
    ypos=y;
    angle=a;
  }

  void draw() {
   stroke(0);
   fill(0);
   pushMatrix();
   translate(xpos,ypos);
   rotate(angle);
   rect(0,0,50,50);
   popMatrix();
   fill(255);
   text(""+fiducial_id, xpos, ypos);
  }
}
