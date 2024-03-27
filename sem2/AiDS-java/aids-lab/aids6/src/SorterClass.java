import java.util.Arrays;
import java.util.Comparator;

public class SorterClass {
    public static void binaryInsertionSort(int[] arr) {
        for (int i = 1; i < arr.length; i++) {
            int key = arr[i];
            int insertIndex = binarySearch(arr, 0, i - 1, key);
            for (int j = i - 1; j >= insertIndex; j--) {
                arr[j + 1] = arr[j];
            }
            arr[insertIndex] = key;
        }
    }

    public static int binarySearch(int[] arr, int left, int right, int key) {
        while (left <= right) {
            int mid = (right + left) / 2;
            if (arr[mid] == key) {
                return mid + 1;
            } else if (arr[mid] > key) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }
        return left;
    }
    public static void selectionSortWithMinMax(int[] arr) {
        int n = arr.length;
        for (int i = 0, j = n - 1; i < j; i++, j--) {
            int minIndex = i, maxIndex = j;
            for (int k = i; k <= j; k++) {
                if (arr[k] < arr[minIndex]) {
                    minIndex = k;
                }
                if (arr[k] > arr[maxIndex]) {
                    maxIndex = k;
                }
            }
            swap(arr, i, minIndex);
            System.out.print(i + " "+ minIndex+"\n");
            if ((i == maxIndex) && (j == minIndex)) {
                System.out.println(Arrays.toString(arr));
                continue;
            }
            System.out.print(j + "h "+ maxIndex+"\n\n");
            if (j == minIndex) swap(arr, i, maxIndex);
            else if (maxIndex == i) swap(arr, j, minIndex);
            else swap(arr, j, maxIndex);
            System.out.println(Arrays.toString(arr));
        }
    }

    public static void swap(int[] arr, int i, int j) {
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
    public static void shakerSort(int[] arr) {
        int n = arr.length;
        int left = 0, right = n - 1;
        while (left <= right) {
            for (int i = left; i < right; i++) {
                if (arr[i] > arr[i + 1]) {
                    swap(arr, i, i + 1);
                }
            }
            right--;
            for (int i = right; i > left; i--) {
                if (arr[i - 1] > arr[i]) {
                    swap(arr, i - 1, i);
                }
            }
            left++;
        }
    }
    public static void main(String[] args) {
        Comparator<Integer> comparator = new MyComparator<>();
        int[] arr = {3, 6, 7, 2, 9, 2, 9, 3, 8, 2};
        System.out.println(Arrays.toString(arr));
        binaryInsertionSort(arr);
        System.out.println(Arrays.toString(arr)); // [1, 2, 3, 4, 5]

        arr = new int[]{3, 6, 7, 2, 9, 2, 9, 3, 8, 2};
        selectionSortWithMinMax(arr);
        System.out.println(Arrays.toString(arr)); // [1, 2, 3, 4, 5]

        arr = new int[]{3, 6, 7, 2, 9, 2, 9, 3, 8, 2};
        shakerSort(arr);
        System.out.println(Arrays.toString(arr)); // [1, 2, 3, 4, 5]
    }
}