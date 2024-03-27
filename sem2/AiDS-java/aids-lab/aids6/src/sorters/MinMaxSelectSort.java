package sorters;

import core.SortingAlgorithm;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class MinMaxSelectSort<T> extends SortingAlgorithm<T> {

	public MinMaxSelectSort(Comparator<? super T> comparator) {
		super(comparator);
	}
	@Override
	public List<T> sort(List<T> list) {
		int n = list.size();
		for (int i = 0, j = n - 1; i < j; i++, j--) {
			int minIndex = i, maxIndex = i;
			T min = list.get(i), max = list.get(i);
			for (int k = i; k <= j; k++) {
				if (comparator.compare(list.get(k), max) >= 0) {
					maxIndex = k;
					max = list.get(k);
				}
				else if (comparator.compare(list.get(k), min) < 0) {
					minIndex = k;
					min = list.get(k);
				}
			}
			//System.out.println(list);
			swapper.swap(list, i, minIndex);
			//System.out.print(i + " "+ minIndex+"\n");
			if(comparator.compare(list.get(minIndex), max) == 0) {swapper.swap(list, j, minIndex);/* System.out.print(j + " "+ minIndex+"\n");*/}
			else {swapper.swap(list, j, maxIndex);/* System.out.print(j + " "+ maxIndex+"\n");*/}
			/*
			System.out.println(list);
			System.out.print(i + " "+ minIndex+"\n");

			if (i != minIndex) swapper.swap(list, i, minIndex);

			if (i == maxIndex && j == minIndex) continue;
			System.out.print(j + "h "+ maxIndex+"\n\n");

			if (i == maxIndex && j != minIndex) swapper.swap(list, j, minIndex);
			else if (j == minIndex && i != maxIndex) swapper.swap(list, i, maxIndex);
			else if (j != maxIndex) swapper.swap(list, j, maxIndex);

			System.out.println(list);
			*/
		}
		//System.out.println("final: " + list);
		return list;
	}
	/*@Override
	public List<T> sort(List<T> list) {
		int size = list.size();
		
		for(int pass = 1; pass < size; ++pass) {
			for(int left = 0; left < (size - pass); ++left) {
				int right = left + 1;
				
				if(comparator.compare(list.get(left), list.get(right)) > 0) {
					swapper.swap(list, left, right);
				}
			}
		}
		
		return list;
	}*/

}
