## Streaming
This project is pretty much a data generator that simulates a stream of data. Under the hood uses the Twitter Streaming
API to fetch live tweets. Later using `spark streaming` it takes care of persisting the live tweets into `S3`.

### Pre-requisites:
* Python 3.7.x
* Spark 2.4.x

```bash
$ brew install apache-spark
$ brew install python3
```

Make sure you set the following env variables:
* `PYTHON_BIN` (usually the output of `which python3.7`)
* `SPARK_HOME` (usually the output of `which spark`)

### Building
```bash
$ ./bin/build.sh
```
### Running
 
#### Producer
```bash
$ ./bin/run_producer.sh -track "#example_hashtag"
``` 

#### Consumer
```bash
$ ./bin/run_consumer.sh
``` 
