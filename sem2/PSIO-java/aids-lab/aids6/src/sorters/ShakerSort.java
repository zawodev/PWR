package sorters;

import core.SortingAlgorithm;

import java.util.Comparator;
import java.util.List;

public class ShakerSort<T> extends SortingAlgorithm<T> {

	public ShakerSort(Comparator<? super T> comparator) {
		super(comparator);
	}
	@Override
	public List<T> sort(List<T> list) {
		int size = list.size();
		boolean swapped = true;
		int start = 0, end = size;

		while(swapped){
			swapped = false;
			for (int i = start; i < end - 1; ++i){
				if(comparator.compare(list.get(i), list.get(i+1)) > 0) {
					swapper.swap(list, i, i+1);
					swapped = true;
				}
			}
			end--;

			if(!swapped) break;

			swapped = false;
			for (int i = end - 1; i >= start; i--){
				if(comparator.compare(list.get(i), list.get(i+1)) > 0) {
					swapper.swap(list, i, i+1);
					swapped = true;
				}
			}
			start++;
		}
		
		return list;
	}

}
