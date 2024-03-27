package counting;
import java.util.Comparator;

public class CountingComparator<T> extends Counter implements Comparator<T> {
	
	private Comparator<? super T> comparator;
	
	public CountingComparator(Comparator<? super T> comparator) {
		super();
		this.comparator = comparator;
	}
	
	public Comparator<? super T> baseComparator() {
		return comparator;
	}
	
	@Override
	public int compare(T lhs, T rhs) {
		increment();
		return comparator.compare(lhs, rhs);
	}

}
