import os
import sys

from pyspark import SparkConf, SparkContext
from pyspark.sql import Row, SQLContext
from pyspark.streaming import StreamingContext


def aggregate_tags_count(new_values, total_sum):
    return sum(new_values) + (total_sum or 0)


def get_sql_context_instance(spark_context):
    if 'sqlContextSingletonInstance' not in globals():
        globals()['sqlContextSingletonInstance'] = SQLContext(spark_context)
    return globals()['sqlContextSingletonInstance']


def send_df_to_s3(df):
    # extract the hashtags from dataframe and convert them into array
    top_tags = [str(t.hashtag) for t in df.select("hashtag").collect()]
    # extract the counts from dataframe and convert them into array
    tags_count = [p.hashtag_count for p in df.select("hashtag_count").collect()]
    print({'label': str(top_tags), 'data': str(tags_count)})


def process_rdd(time, rdd):
    print("----------- %s -----------" % str(time))
    if rdd.isEmpty():
        return
    else:
        try:
            # Get spark sql singleton context from the current context
            sql_context = get_sql_context_instance(rdd.context)
            # convert the RDD to Row RDD
            row_rdd = rdd.map(lambda w: Row(hashtag=w[0], hashtag_count=w[1]))
            # create a DF from the Row RDD
            hashtags_df = sql_context.createDataFrame(row_rdd)
            # Register the dataframe as table
            hashtags_df.registerTempTable("hashtags")
            # get the top 10 hashtags from the table using SQL and print them
            hashtag_counts_df = sql_context.sql(
                "select hashtag, hashtag_count from hashtags order by hashtag_count desc limit 10")
            hashtag_counts_df.show()
            # call this method to prepare top 10 hashtags DF and send them
            send_df_to_s3(hashtag_counts_df)
        except ValueError:
            e = sys.exc_info()[0]
            print("Error while processing RDD's: %s" % e)


def configure_spark_streaming_context():
    conf = SparkConf()
    conf.setAppName("chicago-cloud-conference")
    sc = SparkContext(conf=conf)
    print("Spark driver version: " + sc.version)
    sc.setLogLevel("ERROR")
    ssc = StreamingContext(sc, 2)
    ssc.checkpoint("checkpoint_chicago-cloud-conference")
    return ssc


def main():
    ssc = configure_spark_streaming_context()
    datastream = ssc.socketTextStream(os.getenv('TCP_IP'), int(os.getenv('TCP_PORT')))
    # split each tweet into words
    words = datastream.flatMap(lambda line: line.split(" "))
    # filter the words to get only hashtags, then map each hashtag to be a pair of (hashtag,1)
    hashtags = words.filter(lambda w: '#' in w).map(lambda x: (x, 1))
    # adding the count of each hashtag to its last count
    tags_totals = hashtags.updateStateByKey(aggregate_tags_count)
    # do processing for each RDD generated in each interval
    tags_totals.foreachRDD(process_rdd)
    # start the streaming computation
    ssc.start()
    # wait for the streaming to finish
    ssc.awaitTermination()


if __name__ == "__main__":
    main()
