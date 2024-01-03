package testing.generation.linked;

import java.util.ArrayList;
import java.util.Random;

public class RandomMarkedIntegerLinkedGenerator extends MarkedValueLinkedGenerator<Integer> {
	
	private Random rng;
	private int maxValue;
	
	public RandomMarkedIntegerLinkedGenerator(int maxValue) {
		rng = new Random();
		this.maxValue = maxValue;
	}
	
	public RandomMarkedIntegerLinkedGenerator(int maxValue, long seed) {
		rng = new Random(seed);
		this.maxValue = maxValue;
	}

	@Override
	protected ArrayList<Integer> generateValues(int size) {
		ArrayList<Integer> list = new ArrayList<Integer>(size);
		
		for(int i = 0; i < size; ++i) {
			list.add(rng.nextInt(maxValue));
		}
		
		return list;
	}

}