package ChicagoCloudConference

import java.time.LocalDate

import com.github.mrpowers.spark.daria.sql.EtlDefinition
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions.get_json_object
import org.apache.spark.sql.types.{StringType, StructField, StructType}

class Transformer extends SparkSupport {
  private val schema = StructType(Array(StructField("value", StringType, nullable = true)))

  private val streamingLakeDF: DataFrame = spark.read
    .schema(schema)
    .json(s"s3a://chicago-cloud-conference-2019/bronze/*/*/part-*.json")

  private val etl = EtlDefinition(
    sourceDF = streamingLakeDF,
    transform = parquetTransformer(),
    write = parquetStreamWriter(
      s"s3a://chicago-cloud-conference-2019/silver/${LocalDate.now.toString}",
      s"s3a://chicago-cloud-conference-2019/silver"
    )
  )

  import sqlContext.implicits._
  private def parquetTransformer()(df: DataFrame): DataFrame = {
    df.select(
        get_json_object($"value", "$.created_at").alias("created_at"),
        get_json_object($"value", "$.text").alias("text"),
        get_json_object($"value", "$.user").alias("user")
      )
      .toDF
      .select($"created_at", $"text", $"user")
      .withColumn("location", get_json_object($"user", "$.location"))
      .toDF
      .select($"created_at", $"text", $"location")
  }

  private def parquetStreamWriter(dataPath: String, checkpointPath: String)(df: DataFrame): Unit = {
    df.write
      .parquet(dataPath)
  }

  def start() {
    etl.process()
  }
}

object Transformer {
  def apply() = new Transformer()
}
