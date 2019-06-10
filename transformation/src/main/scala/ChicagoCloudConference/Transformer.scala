package ChicagoCloudConference

import com.github.mrpowers.spark.daria.sql.EtlDefinition
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.types.{StringType, StructField, StructType}

class Transformer extends SparkSupport {
  private val schema = StructType(Array(StructField("value", StringType, nullable = true)))

  private val streamingLakeDF: DataFrame = sqlContext.readStream
    .schema(schema)
    .option("latestFirst", "true")
    .option("maxFilesPerTrigger", "20")
    .json(s"s3a://chicago-cloud-conference-2019/bronze/2019-06-10/*/")

  private val etl = EtlDefinition(
    sourceDF = streamingLakeDF,
    transform = parquetTransformer(),
    write = parquetStreamWriter(
      s"s3a://chicago-cloud-conference-2019/silver/tweets",
      s"s3a://chicago-cloud-conference-2019/silver/checkpoints/tweets"
    )
  )

  private def parquetTransformer()(df: DataFrame): DataFrame = {
    //TODO We need to extract a couple of interesting fields from the raw tweet:
    // 1. time
    // 2. location
    // 3. cleanse text
    // 4. hastags
    df
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
