## Aggregation
This project performs the final data preparation before it gets visualized. The idea is just to read columnar parquet
data from the silver bucket, calculate the required aggregations, and finally write the results back to the gold bucket.

### Pre-requisites:
* R 3.6.x

```bash
$ brew install R
```

Make sure you set the following env variables:
* `R_BIN` (usually the output of `which R`)
* `SPARK_HOME` (usually the output of `which spark`)