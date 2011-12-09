class StateMachine extends Thread {
  long previous_time;
  int bars;
  int beat_per_bar;
  boolean active=true;
  double interval;
  double trigger_interval;
  double control_interval;
  double epsilon = 1.0e-6;
  int event_loop_count = 0;
  int ratio_control_trigger = 10;
  boolean masterPresent = true;
  Counter completion;
  SurfaceObjectList list;
  UDPOutput patternDispatcher;
  int width;
  int height;
  int cy;
  int cx;
  int maxdist;

  StateMachine(double bpm, int bars, int beat_per_bar, SurfaceObjectList list, Counter completion, int width, int height) {
    this.list = list;
    this.beat_per_bar = beat_per_bar;
    this.bars = bars;
    // Interval at which we should trigger new samples, in ms
    trigger_interval = 60 / bpm * bars * beat_per_bar * 1000;
    // State machine frequency : runs multiple times each beat.
    interval = 60 / bpm * 1000 / ratio_control_trigger;
    previous_time = System.nanoTime();
    patternDispatcher = new UDPOutput("127.0.0.1", 3005, 3006);
    this.completion = completion;
    this.width = width;
    this.height = height;
    this.cy = height/2;
    this.cx = width/2;
    this.maxdist = (int)dist(0,0,this.cx,this.cy);
  }

  void run() {
    try {
      while(active) {
        double time_passed = (System.nanoTime() - previous_time) * epsilon;
        while (time_passed < interval) {
          time_passed = (System.nanoTime() - previous_time) * epsilon;
        }

        int total = beat_per_bar * bars * ratio_control_trigger;
        event_loop_count++;
        String message ="";

        if (event_loop_count == total) {
          Enumeration e = list.getAll();
          while (e.hasMoreElements()) {
            SurfaceObject o = (SurfaceObject)e.nextElement();
            message = "t " + o.fiducial_id;
            int x = o.xpos;
            int y = o.ypos;

            println("x: "+x+" y:"+y+" cx: "+cx+" cy: "+cy);

            if (x - cx <= 0 && y - cy <= 0) {
              message += " 2";
            } else if (x - cx <= 0 && y - cy > 0) {
              message += " 1";
            } else if (x - cx > 0 && y - cy <= 0) {
              message += " 3";
            } else if (x - cx > 0 && y - cy > 0) {
              message += " 4";
            }

            message += "\n";

            println(message);

            patternDispatcher.send(message);
          }
          event_loop_count = 0;
        }

        completion.value = (int)(((float)event_loop_count) / total * 100.);

        Enumeration e = list.getAll();
        boolean masterPresentThisRound = false;
        while (e.hasMoreElements()) {
          SurfaceObject o = (SurfaceObject)e.nextElement();
          if (o.fiducial_id == 0) {
            masterPresentThisRound = true;
          }
          message = "c "+ o.fiducial_id +" "
                               + o.xpos / (float)width +" "
                               + o.ypos / (float)height +" "
                               + o.deg+"\n";
          //println("Control message : " + message);
          patternDispatcher.send(message);
          message = "d "+ o.fiducial_id + " "
                        + dist(o.xpos, o.ypos, cx, cy)/(float)maxdist
                        + "\n";
          patternDispatcher.send(message);
        }

        if (masterPresent != masterPresentThisRound) {
          if (masterPresentThisRound == false) {
            patternDispatcher.send("m stop\n");
            println("stop");
          } else {
            patternDispatcher.send("m start\n");
            println("start");
          }
        }

        long delay = (long) (interval - (System.nanoTime() - previous_time) * epsilon);
        if (delay < 0) {
          delay = 0;
        }
        previous_time = System.nanoTime();
        Thread.sleep(delay);
      }
    } 

    catch(InterruptedException e) {
      println("Exception caught, exiting.");
    }
  }
} 

