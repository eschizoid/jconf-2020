package ChicagoCloudConference

import org.apache.spark.SparkContext
import org.apache.spark.sql.{SQLContext, SparkSession}

trait SparkSupport {
  val spark: SparkSession = SparkSession.builder
    .appName("chicago-cloud-conference-2019 - Transformation")
    .master("local[*]")
    .getOrCreate()

  val sc: SparkContext       = spark.sparkContext
  val sqlContext: SQLContext = spark.sqlContext

  private def init(): Unit = {
    sc.setLogLevel("DEBUG")
    sc.hadoopConfiguration.set("fs.s3a.access.key", sys.env("AWS_ACCESS_KEY_ID"))
    sc.hadoopConfiguration.set("fs.s3a.secret.key", sys.env("AWS_SECRET_ACCESS_KEY"))
    sc.hadoopConfiguration.set("fs.s3.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
  }

  init()

  def close(): Unit = {
    spark.close()
  }
}
