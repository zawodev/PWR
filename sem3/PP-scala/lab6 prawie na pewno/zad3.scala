object zad3 {
  //KROK 0: uruchom scale komendą: scala
  //KROK 1: wklej poniższy kod:

  lazy val lazyX: Int = {
    println("Started Calculating Lazy Value...")
    def stirling(n: Int, m: Int): Int = {
      if (m == 1 || n == m) 1
      else if (m > n) 0
      else stirling(n - 1, m - 1) + m * stirling(n - 1, m)
    }
    def my_fun(n: Int): Int = {
      Thread.sleep(2000)
      n * n
    }
    //stirling(13, 7)
    my_fun(2)
  }

  //KROK 2: przeczytaj zmienna "lazyX"
}
