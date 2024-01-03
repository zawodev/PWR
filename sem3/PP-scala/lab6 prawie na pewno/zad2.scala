import scala.collection.mutable

object zad2 {
  private def estimateTime[A, B](f: A => B)(x: A): (B, Double) = {
    val startTime = System.nanoTime
    val fx = f(x)
    val estimatedTime = (System.nanoTime - startTime).toDouble / 1000000
    (fx, estimatedTime)
  }

  private val x = 99
  private val waitTime = 2000

  private def make_memoize[A, B](fun: A => B): A => B = {
    val memo: mutable.HashMap[A, B] = mutable.HashMap()
    (arg: A) => memo.getOrElseUpdate(arg, fun(arg))
  }
  private def my_fun(n: Int): Int = {
    Thread.sleep(waitTime)
    n * n
  }

  def main(args: Array[String]): Unit = {
    val my_fun_memo = make_memoize(my_fun)

    val result1 = estimateTime(my_fun)(x)
    println(s"result 1: ${result1._1}, time: ${result1._2}ms")
    val result2 = estimateTime(my_fun)(x)
    println(s"result 1: ${result2._1}, time: ${result2._2}ms")
    val result3 = estimateTime(my_fun)(x)
    println(s"result 1: ${result3._1}, time: ${result3._2}ms")

    val memoResult1 = estimateTime(my_fun_memo)(x)
    println(s"memoized result 1: ${memoResult1._1}, time: ${memoResult1._2}ms")
    val memoResult2 = estimateTime(my_fun_memo)(x)
    println(s"memoized result 1: ${memoResult2._1}, time: ${memoResult2._2}ms")
    val memoResult3 = estimateTime(my_fun_memo)(x)
    println(s"memoized result 1: ${memoResult3._1}, time: ${memoResult3._2}ms")
  }
}