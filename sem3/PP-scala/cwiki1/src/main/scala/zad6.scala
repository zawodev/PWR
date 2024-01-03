object zad6 {
  def listLength[A](xs: List[A]): Int = {
    def lengthRec(remainingList: List[A], count: Int): Int = {
      remainingList match {
        case Nil => count
        case _ :: tail => lengthRec(tail, count + 1)
      }
    }
    lengthRec(xs, 0)
  }

  def main(args: Array[String]): Unit = {
    val myList = List(1, 2, 3, 4, 5)
    val length = listLength(myList)
    println(myList)
    println(length)
  }
}
