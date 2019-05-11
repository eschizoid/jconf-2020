## Streaming

## Pre-requisites:
* Python 3.7.x
* Spark 2.4.x

```bash
$ brew install spark
$ brew install python3
```

Make sure you set the following env variables:
* `PYTHONPATH`
* `SPARK_HOME`

### Building
```bash
$ ./gradlew build
```
### Running

#### Consumer
```bash
$ ./run_consumer.sh
``` 
#### Producer
```bash
$ ./run_producer.sh
``` 
