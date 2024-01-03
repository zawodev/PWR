package testing.generation.array;

import java.util.ArrayList;
import java.util.List;

import testing.MarkedValue;
import testing.generation.Generator;

public abstract class MarkedValueArrayGenerator<T> implements Generator<MarkedValue<T>> {

	@Override
	public final List<MarkedValue<T>> generate(int size) {
		List<MarkedValue<T>> result = new ArrayList<MarkedValue<T>>();
		
		if(size > 0) {
			for(T value : generateValues(size)) {
				result.add(new MarkedValue<T>(value));
			}
		}
		
		return result;
	}
	
	protected abstract ArrayList<T> generateValues(int size);
}
