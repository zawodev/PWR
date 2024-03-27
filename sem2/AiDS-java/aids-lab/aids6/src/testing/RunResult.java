package testing;

public class RunResult {
	private long timeMillis;
	
	private long comps;
	private long swps;
	
	private boolean srted;
	private boolean stble;
	
	public RunResult(long timeMillis, long comparisons, long swaps, boolean sorted, boolean stable) {
		this.timeMillis = timeMillis;
		this.comps = comparisons;
		this.swps = swaps;
		this.srted = sorted;
		this.stble = stable;
	}
	
	public long timeInMilliseconds() {
		return timeMillis;
	}
	
	public long comparisons() {
		return comps;
	}
	
	public long swaps() {
		return swps;
	}
	
	public boolean sorted() {
		return srted;
	}
	
	public boolean stable() {
		return stble;
	}
}
