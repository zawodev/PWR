object zad4 extends App {
  sealed trait Result[+X]
  case class Success[X](value: X) extends Result[X]
  case class Failure[X](error: String) extends Result[X]

  implicit class ResultOps[X](result: Result[X]) {
    def >>=[Y](f: X => Result[Y]): Result[Y] = result match {
      case Success(value) => f(value)
      case Failure(error) => Failure(error)
    }
  }

  private sealed trait Command
  private case object ADD extends Command
  private case object SUB extends Command
  private case object DIV extends Command
  private case object MUL extends Command

  //========================================================================================================================

  private def f1(input: String): Result[String] = {
    if (input.isEmpty) Failure("Pusty ciąg znaków.")
    else Success(input)
  }

  private def f2(input: String): Result[(Command, List[Int])] = {
    val tokens = input.split("\\s+")
    if (tokens.length == 3) {
      val command = tokens(0) match {
        case "add" => ADD
        case "sub" => SUB
        case "div" => DIV
        case "mul" => MUL
        case other => return Failure(s"Niepoprawna komenda: $other")
      }
      try Success((command, tokens.slice(1, 3).map(_.toInt).toList)) catch {
        case _: NumberFormatException => Failure("Nieprawidłowy format liczby. Powinien byc Int")
      }
    }
    else {
      Failure("Niepoprawna liczba argumentów. Wymagane 2.")
    }
  }

  private def f3(commandTuple: (Command, List[Int])): Result[Int] = {
    val (command, arguments) = commandTuple
    command match {
      case ADD => Success(arguments.sum)
      case SUB => Success(arguments(0) - arguments(1))
      case MUL => Success(arguments.product)
      case DIV =>
        if (arguments(1) != 0) Success(arguments(0) / arguments(1))
        else Failure("Nie można dzielić przez 0.")
    }
  }

  //========================================================================================================================

  private val resultSuccess = Success("add 2 5") >>= f1 >>= f2 >>= f3
  private val resultFailure1 = Success("add h 5") >>= f1 >>= f2 >>= f3
  private val resultFailure2 = Success("asd 2 5") >>= f1 >>= f2 >>= f3

  println(resultSuccess)
  println(resultFailure1)
  println(resultFailure2)
}
