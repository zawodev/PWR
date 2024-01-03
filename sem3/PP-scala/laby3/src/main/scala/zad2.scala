object zad2 {
  def last_two[T](lista: List[T]): Option[(T, T)] = {
    lista match {
      case Nil | List(_) => None
      case List(x, y) => Some((x, y))
      case x :: rest => last_two(rest)
    }
  }

  def main(args: Array[String]): Unit = {
    val list1 = List(1, 2, 3, 4, 5)
    val list2 = List(42)
    val list3 = List()

    val wynik1 = last_two(list1)
    val wynik2 = last_two(list2)
    val wynik3 = last_two(list3)

    println(wynik1)
    println(wynik2)
    println(wynik3)
  }
}
