object zad7 {
  def not_even_destroyer[T](list: List[T], index: Int = 0): List[T] = {
    list match {
      case Nil => Nil // pusta lista pozostaje pusta
      case x :: reszta if index % 2 == 0 => x :: not_even_destroyer(reszta, index + 1) // dodaj element o parzystym indeksie do wyniku
      case _ :: reszta => not_even_destroyer(reszta, index + 1) // pomijaj elementy o nieparzystym indeksie
    }
  }
  def main(args: Array[String]): Unit = {
    val list = List(1, 2, 3, 4, 5, 6, 7, 8)

    println(not_even_destroyer(list))
  }
}
