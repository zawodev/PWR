import scala.collection.mutable

object zad1 {
  private def estimateTime[A, B](f: (A, A) => B)(xy: (A, A)): (B, Double) = {
    val startTime = System.nanoTime
    val fx = f(xy._1, xy._2)
    val estimatedTime = (System.nanoTime - startTime).toDouble / 1000000
    (fx, estimatedTime)
  }
//==============================================================================
  private var normalStirlingCalls = 0
  private var memoizedStirlingCalls = 0
  private def stirling(n: Int, k: Int): Int = {
    normalStirlingCalls += 1
    if (k == 1 || n == k) 1
    else if (k > n) 0
    else stirling(n - 1, k - 1) + k * stirling(n - 1, k)
  }
//===============================================================================
  private val memo: mutable.HashMap[(Int, Int), Int] = mutable.HashMap()
  private def memoized_stirling(n: Int, k: Int): Int = {
    memoizedStirlingCalls += 1
    if (k == 1 || n == k) 1
    else if (k > n) 0
    else memo.getOrElseUpdate((n, k), {memoized_stirling(n - 1, k - 1) + k * memoized_stirling(n - 1, k)})
  }
//===============================================================================
  def main(args: Array[String]): Unit = {
    val n = 11
    val k = 5

    //val result1 = stirling(n, k)
    //val result2 = memoized_stirling(n, k)
    val result1 = estimateTime(stirling)(n, k)
    val result2 = estimateTime(memoized_stirling)(n, k)

    val callsResult = normalStirlingCalls - memoizedStirlingCalls

    println(s"normal stirling result: ${result1._1}")
    println(s"normal stirling calls: $normalStirlingCalls")
    println(s"normal stirling time: ${result1._2}ms")

    println(s"memoized stirling result: ${result2._1}")
    println(s"memoized stirling calls: $memoizedStirlingCalls")
    println(s"memoized stirling time: ${result2._2}ms")

    println(s"calls difference: $callsResult")
  }
}