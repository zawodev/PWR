package testing;

import java.util.HashMap;
import java.util.Map;

public class MarkedValue<T> {
	
	private static Map<Object, Integer> markers = new HashMap<Object, Integer>();
	
	private T val;
	private int mark;
	
	public static void clearMarkers() {
		markers.clear();
	}
	
	public MarkedValue(T value) {
		val = value;
		mark = markers.getOrDefault(value, 1);
		
		markers.put(value, mark + 1);
	}
	
	public T value() {
		return val;
	}
	
	public int marker() {
		return mark;
	}
	public String toString(){ return val.toString();}

}
