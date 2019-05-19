import os
import sys
import time as time_

from pyspark import SparkConf, SparkContext
from pyspark.sql import Row, SQLContext
from pyspark.streaming import StreamingContext


def reverse_current_time_millis():
    return str(int(round(time_.time() * 1000)))[::-1]


def get_sql_context_instance(spark_context):
    if "sqlContextSingletonInstance" not in globals():
        globals()["sqlContextSingletonInstance"] = SQLContext(spark_context)
    return globals()["sqlContextSingletonInstance"]


# TODO figure out how to use the time parameter instead
#  of using the function reverse_current_time_millis()
def process_rdd(time, rdd):
    if rdd.isEmpty():
        return
    else:
        print("----------- %s -----------" % str(time))
        try:
            sql_context = get_sql_context_instance(rdd.context)
            row_rdd = rdd.map(lambda w: Row(twitt=w))
            twitts_df = sql_context.createDataFrame(row_rdd)
            twitts_df.show()
            bucket = f"""s3a://{os.getenv('BUCKET_NAME')}/bronze/{time_.strftime(
                "%Y-%m-%d")}/{reverse_current_time_millis()}"""
            twitts_df.write.csv(bucket=bucket, mode="append", quote='')
        except:
            print("Unexpected error: ", sys.exc_info()[0])
            raise


def configure_spark_streaming_context():
    conf = SparkConf()
    conf.setAppName("chicago-cloud-conference-2019 - Streaming")
    sc = SparkContext(conf=conf)
    print("Spark driver version: " + sc.version)
    hadoop_conf = sc._jsc.hadoopConfiguration()
    hadoop_conf.set("fs.s3.impl", "org.apache.hadoop.fs.s3native.NativeS3FileSystem")
    hadoop_conf.set("fs.s3.awsAccessKeyId", os.getenv("AWS_ACCESS_KEY_ID"))
    hadoop_conf.set("fs.s3.awsSecretAccessKey", os.getenv("AWS_ACCESS_KEY_ID"))
    sc.setLogLevel("ERROR")
    ssc = StreamingContext(sc, 1)
    ssc.checkpoint("checkpoint_chicago-cloud-conference")
    return ssc


def main():
    os.environ["PYSPARK_SUBMIT_ARGS"] = "--packages org.apache.hadoop:hadoop-aws:2.7.3, pyspark-shell"
    ssc = configure_spark_streaming_context()
    datastream = ssc.socketTextStream(os.getenv("TCP_IP"), int(os.getenv("TCP_PORT")))
    datastream.foreachRDD(process_rdd)
    ssc.start()
    ssc.awaitTermination()


if __name__ == "__main__":
    main()
