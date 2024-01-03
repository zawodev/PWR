object zad4 {
  def sqrListD(xs: List[Int]): List[Int] = {
    xs match {
      case Nil => Nil
      case head :: tail => head * head :: sqrListD(tail)
    }
  }
  val sqrListF: List[Int] => List[Int] = {
    case Nil => Nil
    case head :: tail => head * head :: sqrListF(tail)
  }

  def main(args: Array[String]): Unit = {
    val myList = List(1, 2, 3, -4)
    val squaredList1 = sqrListD(myList)
    val squaredList2 = sqrListF(myList)
    println(squaredList1)
    println(squaredList2)
  }
}
