package ChicagoCloudConference

import com.github.mrpowers.spark.daria.sql.EtlDefinition
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.types.{IntegerType, StringType, StructField, StructType}

class Transformer extends SparkSupport {
  private val schema = StructType(
    List(
      StructField("tweet", StringType, nullable = true),
      StructField("timestamp", IntegerType, nullable = true)
    )
  )

  private val streamingLakeDF: DataFrame = spark.readStream
    .format("parquet")
    .schema(schema)
    .load(s"s3a://${sys.env("BUCKET_NAME")}/bronze")

  private val etl = EtlDefinition(
    sourceDF = streamingLakeDF,
    transform = filterMinors(),
    write = parquetStreamWriter(
      s"s3a://${sys.env("BUCKET_NAME")}/silver/tweets",
      s"s3a://${sys.env("BUCKET_NAME")}/silver/checkpoints/tweets"
    )
  )

  private def filterMinors()(df: DataFrame): DataFrame = {
    df.filter(col("timestamp") < System.currentTimeMillis())
  }

  private def parquetStreamWriter(dataPath: String, checkpointPath: String)(df: DataFrame): Unit = {
    df.writeStream
      .trigger(Trigger.Once)
      .format("parquet")
      .option("checkpointLocation", checkpointPath)
      .start(dataPath)
  }

  def start() {
    etl.process()
  }
}

object Transformer {
  def apply() = new Transformer()
}
