object zad1 {
  def last_elem[T](lista: List[T]): Option[T] = {
    lista match {
      case Nil => None
      case x :: Nil => Some(x)
      case _ :: rest => last_elem(rest)
    }
  }
  def main(args: Array[String]): Unit = {
    val lista1 = List(1, 2, 3, 4, 5)
    val lista2 = List()

    val ostatni1 = last_elem(lista1)
    val ostatni2 = last_elem(lista2)

    println(ostatni1)
    println(ostatni2)
  }
}
