object zad2 extends App{
  sealed trait Result[+X] {
    def flatMap[Y](f: X => Result[Y]): Result[Y]
  }
  private case class Success[X](value: X) extends Result[X] {
    override def flatMap[Y](f: X => Result[Y]): Result[Y] = f(value)
  }
  private case class Failure[X](error: String) extends Result[X] {
    override def flatMap[Y](f: X => Result[Y]): Result[Y] = Failure(error)
  }
  private sealed trait Command
  private case object ADD extends Command
  private case object SUB extends Command
  private case object DIV extends Command
  private case object MUL extends Command

  //======================================= F1, F2, F3 =============================================

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


  //======================================== TEST ==============================================

  //"add 2 6"
  //scala.io.StdIn.readLine()
  private val result0: String = scala.io.StdIn.readLine()
  private val result1: Result[String] = f1(result0)
  private val result2: Result[(Command, List[Int])] = result1.flatMap(f2)
  private val result3: Result[Int] = result2.flatMap(f3)

  println(result3)
}
