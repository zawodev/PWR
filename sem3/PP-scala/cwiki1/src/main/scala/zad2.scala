object zad2 {
  def count[A](x: A, xs: List[A]): Int = {
    def countRec(remainingList: List[A], acc: Int): Int = {
      remainingList match {
        case Nil => acc
        case head :: tail =>
          if (head == x) {
            countRec(tail, acc + 1)
          } else {
            countRec(tail, acc)
          }
      }
    }

    countRec(xs, 0)
  }
  def main(args: Array[String]): Unit = {
    val result1 = count('a', List('a', 'l', 'a'))
    val result2 = count('l', List('a', 'l', 'a'))
    println(result1)
    println(result2)
  }
}
