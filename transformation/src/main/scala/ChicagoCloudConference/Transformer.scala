package ChicagoCloudConference

import java.util.regex.Pattern

import com.github.mrpowers.spark.daria.sql.EtlDefinition
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions._
import org.apache.spark.sql.streaming.OutputMode
import org.apache.spark.sql.types.{StringType, StructField, StructType}

import scala.collection.mutable.ListBuffer

class Transformer extends SparkSupport {

  //https://stackoverflow.com/questions/27579474/serialization-exception-on-spark
  object Regex extends Serializable {
    private val pattern = Pattern.compile("#(\\w*[0-9a-zA-Z]+\\w*[0-9a-zA-Z])")

    def extractAll =
      udf((text: String) => {
        val matcher = pattern.matcher(text)
        val result  = ListBuffer.empty[String]
        while (matcher.find()) {
          result += matcher.group()
        }
        result.mkString(",")
      })
  }

  private val schema = StructType(Array(StructField("value", StringType, nullable = true)))
  private val streamingLakeDF = spark.readStream
    .schema(schema)
    .format("json")
    .load(s"s3a://chicago-cloud-conference-2019/bronze/*/*/part-*.json")

  private val etl = EtlDefinition(
    sourceDF = streamingLakeDF,
    transform = parquetTransformer(),
    write = parquetStreamWriter(
      s"s3a://chicago-cloud-conference-2019/silver",
      "checkpoint_transformation_chicago-cloud-conference"
    )
  )

  import sqlContext.implicits._

  private def parquetTransformer()(df: DataFrame): DataFrame = {
    df.select(
        get_json_object($"value", "$.timestamp_ms").alias("timestamp_ms"),
        get_json_object($"value", "$.extended_tweet").alias("extended_tweet"),
        get_json_object($"value", "$.text").alias("text"),
        get_json_object($"value", "$.user").alias("user")
      )
      .withColumn("created_at", to_date(from_unixtime($"timestamp_ms" / 1000), "yyyy-MM-dd"))
      .withColumn("location", get_json_object($"user", "$.location"))
      .withColumn("full_text", get_json_object($"extended_tweet", "$.full_text"))
      .withColumn("text", coalesce($"full_text", $"text"))
      .drop("full_text")
      .na
      .fill("", Seq("text", "location", "hashtags"))
      .withColumn("hashtags", Regex.extractAll($"text"))
      .select($"timestamp_ms", $"created_at", $"text", $"location", $"hashtags")
  }

  private def parquetStreamWriter(dataPath: String, checkpointPath: String)(df: DataFrame): Unit = {
    val query = df
      .repartition($"created_at")
      .writeStream
      .option("checkpointLocation", checkpointPath)
      .option("path", dataPath)
      .option("compression", "uncompressed")
      .outputMode(OutputMode.Append)
      .partitionBy("created_at")
      .start()

    query.awaitTermination()
  }

  def start() {
    etl.process()
  }
}

object Transformer {
  def apply() = new Transformer()
}
