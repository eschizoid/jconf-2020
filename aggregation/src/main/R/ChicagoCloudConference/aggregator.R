library(ggplot2)
library(reshape2)
library(sparklyr)

sc <- sparklyr::spark_connect(master = "local[*]",
appName = "chicago-cloud-conference - Visualization",
spark_home = Sys.getenv("SPARK_HOME"))

version <- sprintf("Spark version: %s", spark_version(sc))
print(version)
