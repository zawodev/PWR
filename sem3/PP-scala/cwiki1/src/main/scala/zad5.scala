object zad5 {
  def palindrome[A](xs: List[A]): Boolean = {
    def reverseList(ys: List[A]): List[A] = {
      ys match {
        case Nil => Nil
        case head :: tail => reverseList(tail) :+ head
      }
    }
    xs == reverseList(xs)
  }
  def main(args: Array[String]): Unit = {
    val list1 = List('a', 'l', 'a')
    val list2 = List('a', 'b', 'c')

    println(palindrome(list1))
    println(palindrome(list2))

  }
}
