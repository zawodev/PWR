object zad3 {
  def list_length[T](list: List[T]): Int = {
    list match {
      case Nil => 0
      case _ :: rest => 1 + list_length(rest)
    }
  }

  def main(args: Array[String]): Unit = {
    val list1 = List(1, 2, 3, 4, 5)
    val list2 = List("a", "b", "c", "d")

    println(list_length(list1))
    println(list_length(list2))
  }
}
