object zad3 extends App {
  sealed trait Result[+X]
  case class Success[X](value: X) extends Result[X]
  case class Failure[X](error: String) extends Result[X]

  private def bind[X, Y](result: Result[X], f: X => Result[Y]): Result[Y] = result match {
    case Success(value) => f(value)
    case Failure(error) => Failure(error)
  }
  private def f(input: String): Result[String] = {
    if (input.length < 5) Failure("Hasło zbyt krótkie.")
    else Success(input)
  }

  private val successResult1: Result[String] = Success("hasło")
  private val successResult2: Result[String] = Success("dom")
  private val failureResult1: Result[String] = Failure("Error 403")
  private val failureResult2: Result[String] = Failure("dom")

  private val result1 = bind(successResult1, f)
  private val result2 = bind(successResult2, f)
  private val result3 = bind(failureResult1, f)
  private val result4 = bind(failureResult2, f)

  println(result1)
  println(result2)
  println(result3)
  println(result4)
}
