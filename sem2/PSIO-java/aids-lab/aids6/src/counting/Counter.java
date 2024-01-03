package counting;

public class Counter {
	private long counter;
	
	public Counter() {
		counter = 0;
	}
	
	public void reset() {
		counter = 0;
	}
	
	public long count() {
		return counter;
	}
	
	protected void increment() {
		++counter;
	}
}
