object zad4 {
  private def bellStream: LazyList[Int] = {
    def sumStirling(n: Int, k: Int): Int = {
      if (n == 0 && k == 0) 1
      else if (n == 0 || k == 0) 0
      else k * sumStirling(n - 1, k) + sumStirling(n - 1, k - 1)
    }

    def generateBell(n: Int): Int =
      (0 to n).map(k => sumStirling(n, k)).sum

    LazyList.from(0).map(generateBell)
  }

  private def lazyListHead[A](lazyList: LazyList[A], n: Int): A =
    lazyList.head

  private def lazyListNthHead[A](lazyList: LazyList[A], n: Int): A =
    lazyList.drop(n).head

  private def lazyListTail[A](lazyList: LazyList[A]): LazyList[A] =
    lazyList.tail

  //fun1
  private def takeFirstN[A](lazyList: LazyList[A], n: Int): List[A] =
    lazyList.take(n).toList
  //fun2
  private def takeEverySecond[A](lazyList: LazyList[A], n: Int): List[A] =
    lazyList.zipWithIndex.filter(_._2 % 2 == 0).map(_._1).take(n).toList
  //fun3
  private def skipFirstN[A](lazyList: LazyList[A], n: Int): LazyList[A] =
    lazyList.drop(n)
  //fun4
  private def zipLazyLists[A, B](s1: LazyList[A], s2: LazyList[B], n: Int): LazyList[(A, B)] =
    s1.zip(s2).take(n)
  //fun5
  private def mapLazyList[A, B](fun: A => B, lazyList: LazyList[A]): LazyList[B] =
    lazyList.map(fun)

  def main(args: Array[String]): Unit = {
    val skipAmount = 4
    val listSize = 8 //czyli n po prostu wszedzie ten sam dla uproszczenia

    val bellNumbers = bellStream
    val naturalNumbers = LazyList.from(1)
    //val squaredNumbers = naturalNumbers.map(x => x * x)

    println("Natural numbers: " + takeFirstN(naturalNumbers, listSize))
    println("Bell numbers: " + takeFirstN(bellNumbers, listSize))
    println("Skipping every second Bell number: " + takeEverySecond(bellNumbers, listSize))
    println(s"Skipping first $skipAmount Bell numbers: " + takeFirstN(skipFirstN(bellNumbers, skipAmount), listSize))

    val zippedLazyList = zipLazyLists(naturalNumbers, bellNumbers, listSize)
    println("Zipped LazyList: " + zippedLazyList.toList)

    val squaredNumbers = mapLazyList((x: Int) => x * x, naturalNumbers)
    println("Squared LazyList: " + takeFirstN(squaredNumbers, listSize))
  }
}
