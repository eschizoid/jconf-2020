# @formatter:off
if (!require(SparkR))
  install.packages("SparkR", repos = "http://cran.us.r-project.org")

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))

library(SparkR)

sc <- sparkR.session(
  master = Sys.getenv("SPARK_MASTER"),
  appName = "chicago-cloud-conference - Aggregation",
  sparkPackages = c("org.apache.hadoop:hadoop-aws:2.7.3")
)

setLogLevel(Sys.getenv("LOGGING_LEVEL"))

version <- sprintf("Spark version: %s", sparkR.version())
print(version)

hConf = SparkR:::callJMethod(sc, "conf")
SparkR:::callJMethod(hConf,
                     "set",
                     "fs.s3a.access.key",
                     Sys.getenv("AWS_ACCESS_KEY_ID"))
SparkR:::callJMethod(hConf,
                     "set",
                     "fs.s3a.secret.key",
                     Sys.getenv("AWS_SECRET_ACCESS_KEY"))
SparkR:::callJMethod(hConf,
                     "set",
                     "fs.s3a.fast.upload", "true")

schema <- structType(
  structField("timestamp_ms", "string"),
  structField("created_at", "string"),
  structField("text", "string"),
  structField("location", "string"),
  structField("hashtags", "string")
)

readStream <- read.stream("parquet",
                          path = "s3a://chicago-cloud-conference-2019/silver/*/part-*.parquet",
                          schema = schema)

transformStream <-
  selectExpr(
    readStream,
    "to_timestamp(cast(timestamp_ms as bigint) / 1000) as timestamp",
    "explode(split(hashtags, ',')) as hashtags"
  )
transformStream <-
  filter(transformStream,
         transformStream$hashtags != "")
transformStream <-
  withWatermark(transformStream,
                "timestamp", "10 minute")
transformStream <- count(groupBy(
  transformStream,
  window(transformStream$timestamp, "5 minute"),
  transformStream$hashtags
))
transformStream <-
  withColumn(transformStream, "grain_size", lit("5m"))

# consoleStream <-
#   write.stream(
#     transformStream,
#     partitionBy = "grain_size",
#     checkpointLocation = "checkpoint_aggregation_chicago-cloud-conference-console",
#     outputMode = "complete",
#     numRows = 50,
#     truncate = FALSE,
#     trigger.processingTime = "1 minutes",
#     "console"
# )

parquetStream <-
  write.stream(
    transformStream,
    partitionBy = "grain_size",
    compression = "none",
    path = "s3a://chicago-cloud-conference-2019/gold",
    checkpointLocation = "checkpoint_aggregation_chicago-cloud-conference-s3",
    outputMode = "append",
    trigger.processingTime = "1 minutes",
    "parquet"
  )

awaitTermination(parquetStream)
