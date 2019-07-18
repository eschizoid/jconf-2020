package ChicagoCloudConference

import org.apache.spark.SparkContext
import org.apache.spark.sql.{SQLContext, SparkSession}

trait SparkSupport {
  val spark: SparkSession = SparkSession.builder
    .config("spark.sql.streaming.checkpointLocation", "checkpoint_transformation_chicago-cloud-conference")
    .config("parquet.compression", "none")
    .appName("chicago-cloud-conference-2019 - Transformation")
    .master(sys.env("SPARK_MASTER"))
    .getOrCreate()

  @transient val sc: SparkContext = spark.sparkContext
  val sqlContext: SQLContext      = spark.sqlContext

  private def init(): Unit = {
    sc.setLogLevel(sys.env("LOGGING_LEVEL"))
    sc.hadoopConfiguration.set("fs.s3a.access.key", sys.env("AWS_ACCESS_KEY_ID"))
    sc.hadoopConfiguration.set("fs.s3a.secret.key", sys.env("AWS_SECRET_ACCESS_KEY"))
    sc.hadoopConfiguration.set("fs.s3a.fast.upload", "true")
  }

  init()

  def close(): Unit = {
    spark.close()
  }
}
