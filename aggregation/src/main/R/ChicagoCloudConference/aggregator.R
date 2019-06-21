library(sparklyr)
library(dplyr)

# Include the org.apache.hadoop:hadoop-aws:2.7.3 package
config <- spark_config()
config$sparklyr.defaultPackages <- "org.apache.hadoop:hadoop-aws:2.7.3"
masterurl <- Sys.getenv("SPARK_MASTER")
print(masterurl)

# Connect to spark
sc <- sparklyr::spark_connect(master = masterurl,
appName = "chicago-cloud-conference - Visualization",
spark_home = Sys.getenv("SPARK_HOME"),
config = config)
ctx <- sparklyr::spark_context(sc)

version <- sprintf("Spark version: %s", spark_version(sc))
print(version)

# Set the java spark context
jsc <- invoke_static(sc, "org.apache.spark.api.java.JavaSparkContext", "fromSparkContext", ctx)

# Set the s3 configs:
hconf <- jsc %>% invoke("hadoopConfiguration")
hconf %>% invoke("set", "fs.s3a.access.key", Sys.getenv("AWS_ACCESS_KEY_ID"))
hconf %>% invoke("set", "fs.s3a.secret.key", Sys.getenv("AWS_SECRET_ACCESS_KEY"))

# Read using sparklyr packages
tweetsparquet <- spark_read_parquet(sc, name = "tweetsparquet", path = "s3a://chicago-cloud-conference-2019/silver/*/part-*.parquet")
head(tweetsparquet)

#TODO perform aggregations before saving to gold bucket
save_aggregations <- function(tweetsparquet, grain_size) {
    sparklyr::spark_write_parquet(tweetsparquet,
    path = toString(glue("s3a://chicago-cloud-conference-2019/gold/{grain}_minute_grain_treding_topic", grain = grain_size)),
    mode = "overwrite")
}

print("Writing 1 minute aggregations...")
save_aggregations(tweetsparquet, 1)
print("Writing 5 minute aggregations...")
save_aggregations(tweetsparquet, 5)
print("Writing 15 minute aggregations...")
save_aggregations(tweetsparquet, 15)
print("Writing 30 minute aggregations...")
save_aggregations(tweetsparquet, 30)
print("Writing 60 minute aggregations...")
save_aggregations(tweetsparquet, 60)
