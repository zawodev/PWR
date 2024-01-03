object zad6 {
  def remove_repeating[T](lista: List[T]): List[T] = {
    def remove_repeating_rec(aktualny: T, reszta: List[T]): List[T] = {
      reszta match {
        case Nil => List(aktualny)
        case x :: xs if x == aktualny => remove_repeating_rec(x, xs)
        case x :: xs => aktualny :: remove_repeating_rec(x, xs)
      }
    }

    lista match {
      case Nil => Nil
      case x :: xs => remove_repeating_rec(x, xs)
    }
  }
  def main(args: Array[String]): Unit = {
    val list1 = List(1, 2, 2, 3, 4, 4, 5)
    val list2 = List("a", "b", "a", "c", "c", "d", "e", "e", "a")

    println(remove_repeating(list1))
    println(remove_repeating(list2))
  }
}
