object zad8 {
  def is_prime(n: Int, devider: Int = 2): Boolean = {
    if (n <= 1)
      false
    else if (n == 2)
      true
    else if (n % devider == 0)
      false
    else if (devider * devider > n)
      true
    else
      is_prime(n, devider + 1)
  }

  def main(args: Array[String]): Unit = {
    val number1 = 2023
    val number2 = 2017 //2027 tez pierwsza

    val is_prime1 = is_prime(number1)
    val is_prime2 = is_prime(number2)

    println(s"Czy $number1 jest liczbą pierwszą?: $is_prime1")
    println(s"Czy $number2 jest liczbą pierwszą?: $is_prime2")
  }

}
