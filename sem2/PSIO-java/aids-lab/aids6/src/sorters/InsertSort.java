package sorters;

import core.SortingAlgorithm;

import java.util.Comparator;
import java.util.List;

public class InsertSort<T> extends SortingAlgorithm<T> {

    public InsertSort(Comparator<? super T> comparator) {
        super(comparator);
    }

    @Override
    public List<T> sort(List<T> list) {
        int size = list.size();
        //System.out.println(list);
        for (int i = 1; i < size; i++) {
            int j = i;
            while (j > 0 && comparator.compare(list.get(j-1), list.get(j)) > 0){
                swapper.swap(list, j, j-1);
                j--;
            }
        }
        //System.out.println(list);
        return list;
    }

    public int linearsearch(List<T> list, int left, int right, T key) {
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
