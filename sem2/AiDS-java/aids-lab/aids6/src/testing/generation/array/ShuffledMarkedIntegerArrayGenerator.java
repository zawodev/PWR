package testing.generation.array;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

public class ShuffledMarkedIntegerArrayGenerator extends MarkedValueArrayGenerator<Integer> {
	
	private Random rng;
	
	public ShuffledMarkedIntegerArrayGenerator() {
		rng = new Random();
	}
	
	public ShuffledMarkedIntegerArrayGenerator(long seed) {
		rng = new Random(seed);
	}

	@Override
	protected ArrayList<Integer> generateValues(int size) {
		ArrayList<Integer> list = new ArrayList<Integer>(size);
		
		for(int i = 0; i < size; ++i) {
			list.add(i);
		}
		
		Collections.shuffle(list, rng);
		
		return list;
	}

}