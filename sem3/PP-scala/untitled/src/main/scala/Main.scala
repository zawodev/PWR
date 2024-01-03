object Main {
  def main(args: Array[String]): Unit = {
    val a = 9
    val b: Int = 2
    print(a+b)
    print(a/b)
    print(a*b)
    print(a-b)

    var c = 9
    val d = 3
    //d = 1 blad
    c = 1
    print(c+d)

    val e: Double = 2.0
    val f: Double = 4.0

    print(e/f)
  }

  //
  def square(x: Int): Unit = {
    return x*x : Int
  }
  //wow
  //def stosunek( x : Double, y: Double): Double = x/y
  //def square(x : Int): Int = x*x
  //def max(x : Int, y: Int): Int = {if(x>y)x else y}

  //def suma(x : Int, y:Int, z:Int): Int = x+y+z
  //def parz(x : Int): Boolean = {if(x%2==0) true else false}

  //==============================WYKLAD 1=====================================
  //scrn z 23/10/2023
  x1 = 7.5
  {
    val x = x1+x1
    val y = 2
    x + x +
    {
      val x = 10.0
      x+y
    }

  } + 1.0

  val k = (7, 2.0, true)
}

val xs = 1.0 :: x1 :: 2.5 :: Nil
xs == List(1,2,3) //porownanie

xs.tail
xs.head


xs.length
xs:::List(1, 2,3)
List(1,2,3).reverse

val double = (x:Int) => 2*x
def twice (x: Int) = 2*x
val twice2 = twice _


def silnia (n:Int):Int = if n==0 then 1 else n*silnia(n-1) else throw new Exception()




def id[A](x:A) = x
id(3 + 4, "siedem")
id(5)





