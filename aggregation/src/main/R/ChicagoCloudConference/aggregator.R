# @formatter:off
if (!require(SparkR))
  install.packages("SparkR", repos = "http://cran.us.r-project.org")
if (!require(glue))
  install.packages("glue", repos = "http://cran.us.r-project.org")

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))

library(SparkR)
library(glue)

sc <- sparkR.session(
  master = Sys.getenv("SPARK_MASTER"),
  appName = "chicago-cloud-conference - Aggreagation",
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
  structField("created_at", "string"),
  structField("text", "string"),
  structField("location", "string"),
  structField("hashtags", "string")
)

read_stream <- read.stream("parquet",
                           path = "s3a://chicago-cloud-conference-2019/silver/*/part-*.parquet",
                           schema = schema)

select_stream <- selectExpr(read_stream, "explode(split(hashtags, ',')) as hashtags")
filtered_stream <- filter(select_stream, select_stream$hashtags != "")

write_stream <- write.stream(filtered_stream,
                             #"parquet",
                             #path = toString(glue("s3a://chicago-cloud-conference-2019/gold/{date}", date = Sys.Date())),
                             checkpointLocation = "checkpoint_aggregation_chicago-cloud-conference",
                             "console")

awaitTermination(write_stream)
