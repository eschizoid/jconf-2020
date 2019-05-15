## Streaming

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
