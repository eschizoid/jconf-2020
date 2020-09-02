package JConf

object Main extends App {
  val transformer = Transformer()
  val version     = transformer.spark.version
  println("SPARK VERSION = " + version)
  transformer.start()
}
