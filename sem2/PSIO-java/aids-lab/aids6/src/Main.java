import java.util.Comparator;

import core.SortingAlgorithm;
import sorters.*;
import testing.*;
import testing.generation.*;
import testing.generation.array.*;

public class Main {

	public static void main(String[] args) {
		Comparator<Integer> comparator = new MyComparator<>();

		Comparator<MarkedValue<Integer>> markedComparator = new MarkedValueComparator<>(comparator);
		Generator<MarkedValue<Integer>> generator = new RandomMarkedIntegerArrayGenerator(10);

		SortingAlgorithm<MarkedValue<Integer>> algorithm = new InsertSort<>(markedComparator);

		Result result = Tester.runNTimes(algorithm, generator, 10000, 20);

		System.out.println("time [ms]: " + result.averageTimeInMilliseconds() + " +- " + result.timeStandardDeviation());
		System.out.println("comparisons: " + result.averageComparisons() + " +- " + result.comparisonsStandardDeviation());
		System.out.println("swaps: " + result.averageSwaps() + " +- " + result.swapsStandardDeviation());
		System.out.println("always sorted: " + result.sorted());
		System.out.println("always stable: " + result.stable());

		/*
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 10, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 100, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 1000, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 2000, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 4000, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 6000, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 8000, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		result = Tester.runNTimes(algorithm, generator, 10000, 20);
		System.out.println(result.averageTimeInMilliseconds() + "\t" + result.timeStandardDeviation() + "\t" + result.averageComparisons() + "\t" + result.comparisonsStandardDeviation() + "\t" + result.averageSwaps() + "\t" + result.swapsStandardDeviation());
		*/
	}
}
