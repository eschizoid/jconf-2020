package ChicagoCloudConference

import org.apache.spark.sql.functions.get_json_object
import org.apache.spark.sql.types.{StringType, StructField, StructType}
import org.scalatest.{FlatSpec, Matchers}

class TransformerSpec extends FlatSpec with Matchers with SparkSupport {

  import sqlContext.implicits._

  "Transformer should" should "yield the columns created_at, text, and location" in {
    val schema = StructType(Array(StructField("value", StringType, nullable = true)))
    val parquet = spark.read
      .schema(schema)
      .json(s"s3a://chicago-cloud-conference-2019/bronze/*/*/part-*.json")
      .select(
        get_json_object($"value", "$.created_at").alias("created_at"),
        get_json_object($"value", "$.text").alias("text"),
        get_json_object($"value", "$.user").alias("user")
      )
      .toDF
      .select($"created_at", $"text", $"user")
      .withColumn("location", get_json_object($"user", "$.location"))
      .toDF
      .select($"created_at", $"text", $"location")
    parquet.foreach(x => println(x))
  }
}
