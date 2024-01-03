package testing.generation.linked;

import java.util.ArrayList;

public class ReversedMarkedIntegerLinkedGenerator extends MarkedValueLinkedGenerator<Integer> {

	@Override
	protected ArrayList<Integer> generateValues(int size) {
		ArrayList<Integer> list = new ArrayList<Integer>(size);
		
		for(int i = size - 1; i >= 0; --i) {
			list.add(i);
		}
		
		return list;
	}

}