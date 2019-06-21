package ChicagoCloudConference

import java.time.LocalDate
import java.util.regex.Pattern

import com.github.mrpowers.spark.daria.sql.EtlDefinition
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions.{coalesce, get_json_object, udf}
import org.apache.spark.sql.streaming.OutputMode
import org.apache.spark.sql.types.{StringType, StructField, StructType}

import scala.collection.mutable.ListBuffer

class Transformer extends SparkSupport {

  //https://stackoverflow.com/questions/27579474/serialization-exception-on-spark
  object Regex extends Serializable {
    private val pattern = Pattern.compile("#(\\w*[0-9a-zA-Z]+\\w*[0-9a-zA-Z])")

    def extractAll =
      udf((text: String) => {
        val matcher = pattern.matcher(if (text == null) "" else text)
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
      s"s3a://chicago-cloud-conference-2019/silver/${LocalDate.now.toString}",
      "checkpoint_transformation_chicago-cloud-conference"
    )
  )

  import sqlContext.implicits._

  private def parquetTransformer()(df: DataFrame): DataFrame = {
    df.select(
        get_json_object($"value", "$.created_at").alias("created_at"),
        get_json_object($"value", "$.extended_tweet").alias("extended_tweet"),
        get_json_object($"value", "$.text").alias("text"),
        get_json_object($"value", "$.user").alias("user")
      )
      .select($"created_at", $"extended_tweet", $"text", $"user")
      .withColumn("location", get_json_object($"user", "$.location"))
      .withColumn("full_text", get_json_object($"extended_tweet", "$.full_text"))
      .select($"created_at", $"full_text", $"text", $"location")
      .withColumn("text", coalesce($"full_text", $"text"))
      .drop("full_text")
      .select($"created_at", $"text", $"location")
      .withColumn("hashtags", Regex.extractAll($"text"))
      .na
      .fill("", Seq("text", "location", "hashtags"))
  }

  private def parquetStreamWriter(dataPath: String, checkpointPath: String)(df: DataFrame): Unit = {
    val query = df.writeStream
      .option("checkpointLocation", checkpointPath)
      .option("path", dataPath)
      .outputMode(OutputMode.Append)
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
