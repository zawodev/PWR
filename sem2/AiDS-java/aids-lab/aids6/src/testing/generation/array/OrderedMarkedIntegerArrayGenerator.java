package testing.generation.array;

import java.util.ArrayList;

public class OrderedMarkedIntegerArrayGenerator extends MarkedValueArrayGenerator<Integer> {

	@Override
	protected ArrayList<Integer> generateValues(int size) {
		ArrayList<Integer> list = new ArrayList<Integer>(size);
		
		for(int i = 0; i < size; ++i) {
			list.add(i);
		}
		
		return list;
	}

}
