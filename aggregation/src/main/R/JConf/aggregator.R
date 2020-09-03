if (nchar(Sys.getenv("SPARK_HOME")) < 1) {
  Sys.setenv(SPARK_HOME = "/opt/spark")
}
library(SparkR, lib.loc = file.path(Sys.getenv("SPARK_HOME"), "R", "lib"))

sc <- sparkR.session(
  master = Sys.getenv("SPARK_MASTER"),
  appName = "jconf - Aggregation"
)

setLogLevel(Sys.getenv("LOGGING_LEVEL"))

version <- sprintf("Spark version: %s", sparkR.version())
print(version)

hConf <- SparkR:::callJMethod(sc, "conf")
SparkR:::callJMethod(hConf,
                     "set",
                     "fs.s3a.access.key",
                     Sys.getenv("AWS_ACCESS_KEY_ID"))
SparkR:::callJMethod(hConf,
                     "set",
                     "fs.s3a.secret.key",
                     Sys.getenv("AWS_SECRET_ACCESS_KEY"))

schema <- structType(
  structField("timestamp_ms", "string"),
  structField("created_at", "string"),
  structField("text", "string"),
  structField("location", "string"),
  structField("hashtags", "string")
)

readStream <- read.stream("parquet",
                          path = "s3a://jconf-2020/silver/*/part-*.parquet",
                          schema = schema)

selectStream <- selectExpr(
  readStream,
  "to_timestamp(cast(timestamp_ms as bigint) / 10000) as timestamp",
  "explode(split(hashtags, ',')) as hashtags"
)
filterStream <- filter(selectStream, selectStream$hashtags != "")
watermarkStream <- withWatermark(filterStream, "timestamp", "240 hours")
countStream <- count(
  groupBy(
    filterStream,
    window(watermarkStream$"timestamp", "24 hour"),
    watermarkStream$hashtags
  )
)
withColumnStream <- withColumn(countStream, "grain_size", lit("24h"))
repartitionStream <- repartition(withColumnStream, col = withColumnStream$"grain_size")

#consoleStream <-
#  write.stream(
#    transformStream,
#    partitionBy = "grain_size",
#    checkpointLocation = "checkpoint_aggregation_jconf-console",
#    outputMode = "complete",
#    numRows = 50,
#    truncate = FALSE,
#    trigger.processingTime = "1 minutes",
#    "console"
#)

parquetStream <-
  write.stream(
    repartitionStream,
    compression = "none",
    path = "s3a://jconf-2020/gold/24h",
    checkpointLocation = "checkpoint_aggregation_jconf",
    outputMode = "append",
    trigger.processingTime = "1 minutes",
    "parquet"
  )

awaitTermination(parquetStream)
