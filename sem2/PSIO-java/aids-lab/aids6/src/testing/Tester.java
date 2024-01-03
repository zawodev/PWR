package testing;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

import core.SortingAlgorithm;
import testing.generation.Generator;

public class Tester {
	
	public static <T> RunResult runOnce(SortingAlgorithm<MarkedValue<T>> algorithm, Generator<MarkedValue<T>> generator, int size) {
		algorithm.reset();
		
		List<MarkedValue<T>> list = generator.generate(size);
		
		Instant start = Instant.now();
		algorithm.sort(list);
		Instant end = Instant.now();
		
		return new RunResult(Duration.between(start, end).toMillis(), algorithm.comparisons(), algorithm.swaps(), 
				ListChecker.isSorted(list, algorithm.baseComparator()), ListChecker.isStable(list, algorithm.baseComparator()));
	}
	
	public static <T> Result runNTimes(SortingAlgorithm<MarkedValue<T>> algorithm, Generator<MarkedValue<T>> generator, 
			int size, int repetitions) {
		double averageTime = 0.0;
		double averageTimeSquared = 0.0;
		
		double averageComparisons = 0.0;
		double averageComparisonsSquared = 0.0;
		
		double averageSwaps = 0.0;
		double averageSwapsSquared = 0.0;
		
		boolean sorted = true;
		boolean stable = true;
		
		for(int n = 1; n <= repetitions; ++n) {
			RunResult result = runOnce(algorithm, generator, size);
			
			averageTime = updatedAverage(averageTime, result.timeInMilliseconds(), n);
			averageTimeSquared = updatedAverage(averageTimeSquared, 
					(double)result.timeInMilliseconds() * (double)result.timeInMilliseconds(), n);
			
			averageComparisons = updatedAverage(averageComparisons, result.comparisons(), n);
			averageComparisonsSquared = updatedAverage(averageComparisonsSquared, 
					(double)result.comparisons() * (double)result.comparisons(), n);
			
			averageSwaps = updatedAverage(averageSwaps, result.swaps(), n);
			averageSwapsSquared = updatedAverage(averageSwapsSquared, (double)result.swaps() * (double)result.swaps(), n);
			
			sorted = sorted && result.sorted();
			stable = stable && result.stable();
		}
		
		return new Result(averageTime, calculateStdDev(averageTime, averageTimeSquared), 
				averageComparisons, calculateStdDev(averageComparisons, averageComparisonsSquared), 
				averageSwaps, calculateStdDev(averageSwaps, averageSwapsSquared), 
				sorted, stable);
	}
	
	private static double updatedAverage(double average, double value, int n) {
		return average + (value - average) / n;
	}
	
	private static double calculateStdDev(double average, double averageSquare) {
		return Math.sqrt(averageSquare - (average * average));
	}
	
}
