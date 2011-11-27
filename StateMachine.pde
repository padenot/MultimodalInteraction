class StateMachine extends Thread {
  long previous_time;
  int bars;
  int beat_per_bar;
  boolean active=true;
  double interval;
  double trigger_interval;
  double epsilon = 1.0e-6;
  int barcount = 0;
  SurfaceObjectList list;
  UDPOutput patternDispatcher;

  StateMachine(double bpm, int bars, int beat_per_bar, SurfaceObjectList list) {
    this.list = list;
    this.beat_per_bar = beat_per_bar;
    this.bars = bars;
    // State machine frequency : runs each beat.
    interval = 60 / bpm * 1000;
    // Interval at which we should trigger new samples, in ms
    trigger_interval = 60 / bpm * bars * beat_per_bar * 1000;
    previous_time = System.nanoTime();
    patternDispatcher = new UDPOutput("127.0.0.1", 3005, 3006);
  }

  void run() {
    try {
      while(active) {
        double time_passed = (System.nanoTime() - previous_time) * epsilon;
        while (time_passed < interval) {
          time_passed = (System.nanoTime() - previous_time) * epsilon;
        }

        barcount++;
        String message ="";
        message += barcount + "/" + beat_per_bar * bars;
        println(message);

        if (barcount == beat_per_bar * bars) {
          println("New samples triggered");
          Enumeration e = list.getAll();
          while (e.hasMoreElements()) {
            TuiObject o = (TuiObject)e.nextElement();
            patternDispatcher.send(o.fiducial_id+"\n");
          }
          barcount = 0;
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

