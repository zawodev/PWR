object zad3 {
  private def replicate[A](x: A, n: Int): List[A] = {
    if (n <= 0) {
      Nil
    } else {
      x :: replicate(x, n - 1)
    }
  }
  def main(args: Array[String]): Unit = {
    val result1 = replicate("la", 3)
    val result2 = replicate("ra", 5)
    println(result1)
    println(result2)
  }
}
