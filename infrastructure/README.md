## Infrastructure

### Installing dependencies
```bash
$ brew cask install minikube 
$ brew install kubectl
```

### Starting `minikube`
```bash
$ minikube start --cpus 5 --memory 8192
```

### Stopping `minikube`
```bash
$ minikube stop
```

### Monitoring `minikube`
```bash
$ minikuke dashboard
```

### Building `docker` images
```bash
$ ./bin/build_dockerf_images.sh
```

### Permissions for spark jobs
```bash
$ kubectl apply -n minikube -f spark-rbac.yaml
```

### Submitting spark job to `minikube`
```bash
$ ./spark-submit \
    --master k8s://https://192.168.99.100:8443 \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.executor.instances=3 \
    --conf spark.kubernetes.container.image=docker.io/eschizoid/spark:base \
    local:///opt/spark/examples/target/original-spark-examples_2.11-2.4.2.jar
```
