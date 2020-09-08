## Visualization
Once the aggregated data is available, we can proceed to read it and finally visual it with Zeppelin.

### Accessing Zeppelin UI
To visualize the aggregations first we need to make the notebook accessible by executing the command bellow:

```bash
$ kubectl port-forward zeppelin-server 8080:80
```

Zeppelin UI should be accessible using the url  ```http://localhost:8080```

### Importing Notebook
Import the file ```$(pwd)/jconf-2020/visualization/src/resources/JConf 2020 - Visualization.zpln``` into Zeppelin.

![](../images/notebook_import.png)

### Spark interpreter settings
Add the following properties to the spark interpreter:
```
SPARK_SUBMIT_OPTIONS --conf spark.jars.ivy=/tmp/.ivy
SPARK_USER zeppelin
```

### Running Notebook
After importing the notebook run it and you should see an image similar to the one bellow:

![](../images/notebook.png)


