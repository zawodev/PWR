object zad1 extends App {
  sealed trait Result[+X]
  case class Success[X](value: X) extends Result[X]
  case class Failure[X](error: String) extends Result[X]

  private val successResult: Result[Int] = Success(42)
  private val failureResult: Result[Double] = Failure("Error 404")

  println(successResult)
  println(failureResult)
}
