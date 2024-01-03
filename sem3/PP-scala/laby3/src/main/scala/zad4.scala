object zad4 {
  def reverse_list[T](list: List[T]): List[T] = {
    list match {
      case Nil => Nil
      case x :: rest => reverse_list(rest) ::: List(x)
    }
  }

  def main(args: Array[String]): Unit = {
    val list1 = List(1, 2, 3, 4, 5)
    val list2 = List("a", "b", "c", "d")

    println(reverse_list(list1))
    println(reverse_list(list2))
  }
}
