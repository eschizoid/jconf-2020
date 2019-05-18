## Streaming

This project is pretty much a data generator that simulates a stream of data. Under the hood uses the Twitter Streaming
API to fetch live tweets. Later using `spark straming` it takes care of persisting the live tweets into `S3`.

### Pre-requisites:
* Python 3.7.x
* Spark 2.4.x

```bash
$ brew install spark
$ brew install python3
```

Make sure you set the following env variables:
* `PYTHON_BIN`
* `PYTHONPATH`
* `SPARK_HOME`

### Building
```bash
$ ./streaming/bin/build.sh
```
### Running

#### Consumer
```bash
$ ./streaming/bin/run_consumer.sh
``` 
#### Producer
```bash
$ ./streaming/bin/run_producer.sh
``` 
