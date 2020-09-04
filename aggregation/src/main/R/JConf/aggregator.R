if (nchar(Sys.getenv("SPARK_HOME")) < 1) {
  Sys.setenv(SPARK_HOME = "/opt/spark")
}
library(SparkR, lib.loc = file.path(Sys.getenv("SPARK_HOME"), "R", "lib"))

sc <- sparkR.session(
  master = Sys.getenv("SPARK_MASTER"),
  appName = "jconf - Aggregation",
  sparkPackages = "org.apache.hadoop:hadoop-aws:3.2.0"
)

setLogLevel(Sys.getenv("LOGGING_LEVEL"))

version <- sprintf("Spark version: %s", sparkR.version())
print(version)

hConf <- SparkR:::callJMethod(sc, "conf")
SparkR:::callJMethod(
  hConf,
  "set",
  "fs.s3a.access.key",
  Sys.getenv("AWS_ACCESS_KEY_ID")
)
SparkR:::callJMethod(
  hConf,
  "set",
  "fs.s3a.secret.key",
  Sys.getenv("AWS_SECRET_ACCESS_KEY")
)

schema <- structType(
  structField("timestamp_ms", "string"),
  structField("created_at", "string"),
  structField("text", "string"),
  structField("location", "string"),
  structField("hashtags", "string")
)

transformStream <- read.stream(
  "parquet",
  path = "s3a://jconf-2020/silver/*/part-*.parquet",
  schema = schema
)

transformStream <- selectExpr(
  transformStream,
  "to_timestamp(cast(timestamp_ms as bigint) / 1000) as timestamp",
  "explode(split(hashtags, ',')) as hashtags"
)
transformStream <- filter(transformStream, transformStream$hashtags != "")
transformStream <- withWatermark(transformStream, "timestamp", "5 minutes")
transformStream <- count(
  groupBy(
    transformStream,
    window(transformStream$"timestamp", "5 minutes"),
    transformStream$hashtags
  )
)
transformStream <- withColumn(transformStream, "grain_size", lit("5m"))
transformStream <- repartition(transformStream, col = transformStream$"grain_size")

transformStream <- write.stream(
  transformStream,
  partitionBy = "grain_size",
  path = "s3a://jconf-2020/gold",
  checkpointLocation = "checkpoint_aggregation_jconf",
  outputMode = "append",
  trigger.processingTime = "1 minutes"
)

#transformStream <-
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

awaitTermination(transformStream)

