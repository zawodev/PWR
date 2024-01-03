package testing.generation.array;

import java.util.ArrayList;

public class ReversedMarkedIntegerArrayGenerator extends MarkedValueArrayGenerator<Integer> {

	@Override
	protected ArrayList<Integer> generateValues(int size) {
		ArrayList<Integer> list = new ArrayList<Integer>(size);
		
		for(int i = size - 1; i >= 0; --i) {
			list.add(i);
		}
		
		return list;
	}

}