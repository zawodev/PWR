object zad1 {
  def flatten1[A](xss: List[List[A]]): List[A] = {
    def flattenRecursive(remainingLists: List[List[A]], result: List[A]): List[A] = {
      remainingLists match {
        case Nil => result //empty list
        case headList :: tailLists =>
          flattenRecursive(tailLists, appendList(result, headList))
      }
    }

    def appendList(list1: List[A], list2: List[A]): List[A] = {
      list1 match {
        case Nil => list2
        case head :: tail => head :: appendList(tail, list2)
      }
    }

    flattenRecursive(xss, List.empty[A])
  }

  def count [T](el: T, lst: List[T]):Int = {
    if (lst == Nil) 0
    else lst.head. + count(lst, tail)
  }

  def main(args: Array[String]): Unit = {
    val listOfLists = List(List(5, 6), List(1, 2, 3))
    val flattenedList = flatten1(listOfLists)
    println(listOfLists)
    println(flattenedList)
  }
}