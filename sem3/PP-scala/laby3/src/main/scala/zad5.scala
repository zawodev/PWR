object zad5 {
  def palindrome[A](xs: List[A]): Boolean = {
    def reverse_list(ys: List[A]): List[A] = {
      ys match {
        case Nil => Nil
        case head :: tail => reverse_list(tail) :+ head
      }
    }
    xs == reverse_list(xs)
  }
  def main(args: Array[String]): Unit = {
    val list1 = List('a', 'l', 'a')
    val list2 = List('a', 'b', 'c')

    println(palindrome(list1))
    println(palindrome(list2))
  }
}
