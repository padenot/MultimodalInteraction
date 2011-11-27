/*
        TUIO processing library - part of the reacTIVision project
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

package tuio;

import java.awt.event.*;
import java.lang.reflect.*;
import processing.core.*;
import com.illposed.osc.*;
import java.util.*;


public class TuioClient implements OSCListener {
	int port = 3333;
	
	private OSCPortIn oscPort;
	private Hashtable objectList = new Hashtable();
	private Vector aliveObjectList = new Vector();
	private Vector newObjectList = new Vector();
	private Vector aliveCursorList = new Vector();
	private Vector newCursorList = new Vector();
	
	private int currentFrame = 0;
	private int lastFrame = 0;
	
	PApplet parent;
	Method addTuiObject, removeTuiObject, updateTuiObject, addTuiCursor, removeTuiCursor, updateTuiCursor, refresh;
	
	public TuioClient(PApplet parent) {
		this(parent,3333);
	}

	public TuioClient(PApplet parent, int port) {
		this.parent = parent;
		this.port=port;
		parent.registerDispose(this);
		
		try { refresh = parent.getClass().getMethod("refresh",new Class[0]); }
		catch (Exception e) { }
		
		try { addTuiObject = parent.getClass().getMethod("addTuiObject", new Class[] { Integer.class, Integer.class  }); }
		catch (Exception e) { }
		
		try { removeTuiObject = parent.getClass().getMethod("removeTuiObject", new Class[] { Integer.class, Integer.class }); }
		catch (Exception e) { }
		
		try { updateTuiObject = parent.getClass().getMethod("updateTuiObject", new Class[] { Integer.class, Integer.class, Float.class, Float.class, Float.class}); }
		catch (Exception e) { }
		
		try { addTuiCursor = parent.getClass().getMethod("addTuiCursor", new Class[] { Integer.class }); }
		catch (Exception e) { }
		
		try { removeTuiCursor = parent.getClass().getMethod("removeTuiCursor", new Class[] { Integer.class }); }
		catch (Exception e) { }
		
		try { updateTuiCursor = parent.getClass().getMethod("updateTuiCursor", new Class[] { Integer.class, Float.class, Float.class}); }
		catch (Exception e) { }
		
		try {
			oscPort = new OSCPortIn(port);
			oscPort.addListener("/tuio/2Dobj",this);
			oscPort.addListener("/tuio/2Dcur",this);
			oscPort.startListening();
		} catch (Exception e) {
			System.out.println("failed to connect to port "+port);
		}
	}


	public void acceptMessage(Date date, OSCMessage message) {
	
		Object[] args = message.getArguments();
		String command = (String)args[0];
		String address = message.getAddress();
			
		if (address.equals("/tuio/2Dobj")) {
			
			if ((command.equals("set")) && (currentFrame>=lastFrame)) {
				if (updateTuiObject!=null) {
	
					if (objectList.get(args[1]) == null) {
						objectList.put(args[1],args[2]);
						try { addTuiObject.invoke(parent, new Object[] { args[1], args[2] }); }
						catch (Exception e) { addTuiObject = null; }
					}
	
					try { updateTuiObject.invoke(parent, new Object[] { args[1], args[2], args[3], args[4], args[5] }); }
					catch (Exception e) { updateTuiObject = null; }
				}
				
			} else if ((command.equals("alive")) && (currentFrame>=lastFrame)) {
						
				for (int i=1;i<args.length;i++) {
					// get the message content
					newObjectList.addElement(args[i]);
					// reduce the object list to the lost objects
					if (aliveObjectList.contains(args[i])) aliveObjectList.removeElement(args[i]);
				}
				
				// remove the remaining objects
				for (int i=0;i<aliveObjectList.size();i++) {
					Integer s_id = (Integer)aliveObjectList.elementAt(i);
					Integer f_id = (Integer)objectList.remove(aliveObjectList.elementAt(i));
					try { removeTuiObject.invoke(parent, new Object[] { s_id, f_id }); }
					catch (Exception e) { removeTuiObject = null; }
				}
				
				Vector buffer = aliveObjectList;
				aliveObjectList = newObjectList;
				
				// recycling of the vector
				newObjectList = buffer;
				newObjectList.clear();
					
			} else if (command.equals("fseq")) {
				lastFrame = currentFrame;
				currentFrame = ((Integer)args[1]).intValue();
				
				if ((currentFrame<0) || (currentFrame>lastFrame)) {
					try { refresh.invoke(parent,null); }
					catch (Exception e) { refresh = null; }
				}
			}
		} else if (address.equals("/tuio/2Dcur")) {
	
			if ((command.equals("set")) && (currentFrame>=lastFrame)) {
				Integer s_id  = (Integer)args[1];
				Float x = (Float)args[2];
				Float y = (Float)args[3];
				Float X = (Float)args[4];
				Float Y = (Float)args[5];
				Float m = (Float)args[6];
	
				try { updateTuiCursor.invoke(parent, new Object[] { s_id, x, y }); }
				catch (Exception e) { updateTuiCursor = null; }
	
			} else if ((command.equals("alive")) && (currentFrame>=lastFrame)) {
		
				for (int i=1;i<args.length;i++) {
					// get the message content
					newCursorList.addElement(args[i]);
					// reduce the object list to the lost objects
					if (aliveCursorList.contains(args[i])) 
						aliveCursorList.removeElement(args[i]);
					else {
						try { addTuiCursor.invoke(parent, new Object[] { args[i] }); }
						catch (Exception e) { addTuiCursor = null; }
					}
				}
					
				// remove the remaining objects
				for (int i=0;i<aliveCursorList.size();i++) {
					Integer s_id = (Integer)aliveCursorList.elementAt(i);
					//System.out.println("remove "+id);
					try { removeTuiCursor.invoke(parent, new Object[] { s_id }); }
					catch (Exception e) { removeTuiCursor = null; }
				}
					
				Vector buffer = aliveCursorList;
				aliveCursorList = newCursorList;
	
				// recycling of the vector
				newCursorList = buffer;
				newCursorList.clear();
			}
		}
	}

	public void pre() {
		//method that's called just after beginFrame(), meaning that it 
		//can affect drawing.
	}

	public void draw() {
		//method that's called at the end of draw(), but before endFrame().
	}
	
	public void mouseEvent(MouseEvent e) {
		//called when a mouse event occurs in the parent applet
	}
	
	public void keyEvent(KeyEvent e) {
		//called when a key event occurs in the parent applet
	}
	
	public void post() {
		//method called after draw has completed and the frame is done.
		//no drawing allowed.
	}
	
	public void size(int width, int height) {
		//this will be called the first time an applet sets its size, but
		//also any time that it's called while the PApplet is running.
	}
	
	public void stop() {
		//can be called by users, for instance movie.stop() will shut down
		//a movie that's being played, or camera.stop() stops capturing 
		//video. server.stop() will shut down the server and shut it down
		//completely, which is identical to its "dispose" function.
	}
	
	public void dispose() {
	
		oscPort.stopListening();
		try { Thread.sleep(100); }
		catch (Exception e) {};
		oscPort.close();
	
		//this should only be called by PApplet. dispose() is what gets 
		//called when the host applet is stopped, so this should shut down
		//any threads, disconnect from the net, unload memory, etc. 
	}
}
