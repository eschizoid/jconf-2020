package ChicagoCloudConference

final case class Person(firstName: String, lastName: String, country: String, age: Int)

object Main extends App with InitSpark {
  val version = spark.version
  println("SPARK VERSION = " + version)

  val sumHundred = spark.range(1, 101).reduce(_ + _)
  println(f"Sum 1 to 100 = $sumHundred")

  close
}
