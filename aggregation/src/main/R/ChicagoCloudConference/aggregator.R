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

schema <- structType(
  structField("timestamp_ms", "string"),
  structField("created_at", "string"),
  structField("text", "string"),
  structField("location", "string"),
  structField("hashtags", "string")
)

read_stream <- read.stream("parquet",
                           path = "s3a://chicago-cloud-conference-2019/silver/*/part-*.parquet",
                           schema = schema)

select_stream <-
  selectExpr(
    read_stream,
    "to_timestamp(cast(timestamp_ms as bigint) / 1000) as timestamp",
    "explode(split(hashtags, ',')) as hashtags"
  )
filtered_stream <-
  filter(select_stream,
         select_stream$hashtags != "")
watermarked_stream <-
  withWatermark(filtered_stream,
                "timestamp", "10 minutes")
windowed_stream <- count(groupBy(
  watermarked_stream,
  window(watermarked_stream$timestamp, "5 minutes"),
  watermarked_stream$hashtags
))

write_stream <-
  write.stream(
    windowed_stream,
    # "parquet",
    # path = "s3a://chicago-cloud-conference-2019/gold",
    checkpointLocation = "checkpoint_aggregation_chicago-cloud-conference",
    outputMode = "update",
    numRows = 50,
    truncate = FALSE,
    "console"
  )

awaitTermination(write_stream)
