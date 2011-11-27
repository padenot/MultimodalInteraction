public class SurfaceObjectList extends TuiObjectList
{
  void activate(Integer s_id, Integer f_id) 
  { 
    TuiObject nobj = new SurfaceObject(s_id.intValue(), f_id.intValue());
    objectList.put(s_id,nobj);
  }
}
