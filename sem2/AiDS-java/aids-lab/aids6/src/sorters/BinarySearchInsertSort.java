package sorters;

import core.SortingAlgorithm;

import java.util.Comparator;
import java.util.List;

public class BinarySearchInsertSort<T> extends SortingAlgorithm<T> {

	public BinarySearchInsertSort(Comparator<? super T> comparator) {
		super(comparator);
	}

	@Override
	public List<T> sort(List<T> list) {
		int size = list.size();
		//System.out.println(list);
		for (int i = 1; i < size; i++) {
			T key = list.get(i);
			int insertIndex = binarySearch(list, 0, i - 1, key);
			for (int j = i - 1; j >= insertIndex; j--) {
				//list.set(j+1, list.get(j));
				swapper.swap(list, j+1, j+0);
			}
			//list.set(insertIndex, key);
		}
		//System.out.println(list);
		return list;
	}

	public int binarySearch(List<T> list, int left, int right, T key) {
		while (left <= right) {
			int mid = (right + left) / 2;
			if (comparator.compare(list.get(mid), key) > 0) {
				right = mid - 1;
			}
			else {
				left = mid + 1;
				//1 3 3 3 4 4
				//0 1 2 3 4 5
			}
		}
		return left;
	}
}
