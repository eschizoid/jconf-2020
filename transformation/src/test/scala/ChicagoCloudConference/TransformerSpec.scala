package ChicagoCloudConference

import java.util.regex.Pattern

import org.apache.spark.sql.functions.{coalesce, from_unixtime, get_json_object, to_date, udf}
import org.apache.spark.sql.streaming.OutputMode
import org.apache.spark.sql.types.{StringType, StructField, StructType}
import org.scalatest.{FlatSpec, Matchers}

import scala.collection.mutable.ListBuffer

class TransformerSpec extends FlatSpec with Matchers with SparkSupport {

  import sqlContext.implicits._

  "Transformer should" should "yield the columns created_at, text, location, and hashtags" in {

    val pattern = Pattern.compile("#(\\w*[0-9a-zA-Z]+\\w*[0-9a-zA-Z])")

    def regexp_extractAll =
      udf((text: String) => {
        val matcher = pattern.matcher(text)
        val result  = ListBuffer.empty[String]
        while (matcher.find()) {
          result += matcher.group()
        }
        result.mkString(",")
      })

    val schema = StructType(Array(StructField("value", StringType, nullable = true)))
    val parquet = spark.readStream
      .schema(schema)
      .format("json")
      .load(s"s3a://chicago-cloud-conference-2019/bronze/*/*/part-*.json")
      .select(
        get_json_object($"value", "$.timestamp_ms").alias("timestamp_ms"),
        get_json_object($"value", "$.extended_tweet").alias("extended_tweet"),
        get_json_object($"value", "$.text").alias("text"),
        get_json_object($"value", "$.user").alias("user")
      )
      .withColumn("created_at", to_date(from_unixtime($"timestamp_ms" / 1000), "yyyy-MM-dd"))
      .select($"created_at", $"extended_tweet", $"text", $"user")
      .withColumn("location", get_json_object($"user", "$.location"))
      .withColumn("full_text", get_json_object($"extended_tweet", "$.full_text"))
      .select($"created_at", $"full_text", $"text", $"location")
      .withColumn("text", coalesce($"full_text", $"text"))
      .drop("full_text")
      .select($"created_at", $"text", $"location")
      .na
      .fill("", Seq("text", "location", "hashtags"))
      .withColumn("hashtags", regexp_extractAll($"text"))

    val query = parquet
      .repartition($"created_at")
      .writeStream
      .option("checkpointLocation", "checkpoint_transformation_chicago-cloud-conference")
      .option("path", s"s3a://chicago-cloud-conference-2019/silver")
      .outputMode(OutputMode.Append)
      .partitionBy("created_at")
      .start()

    query.awaitTermination(10000)
  }
}
