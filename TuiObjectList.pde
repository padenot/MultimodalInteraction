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

class TuiObjectList 
{

  java.util.Hashtable objectList;

  TuiObjectList() {
    textFont(createFont("Sans", 12));
    objectList = new Hashtable();
  }

  void draw() { 
    Enumeration e = objectList.elements();
    while (e.hasMoreElements()) {
      ((TuiObject)e.nextElement()).draw();
    }
  }

  Enumeration getAll() {
    return objectList.elements();
  }

  TuiObject getObject(Integer s_id) {
    return (TuiObject)objectList.get(s_id);
  }
  
  void activate(Integer s_id, Integer f_id) { 
    TuiObject nobj = new TuiObject(s_id.intValue(), f_id.intValue());
    objectList.put(s_id,nobj);
  }
  
  void deactivate(Integer s_id) {
    objectList.remove(s_id);
  }
  void update(Integer s_id, int x, int y, float a) {
    TuiObject tobj = (TuiObject)objectList.get(s_id);
    if (tobj!=null) tobj.update(x,y,a);
  }
}
