## Infrastructure

## EKS Deployment

### Installing dependencies
```bash
$ brew install gettext
$ brew install awscli
$ brew tap weaveworks/tap
$ brew install weaveworks/tap/eksctl
```

### Starting `eks`
```bash
$ eksctl create cluster \
  --name=jconf-2020 \
  --nodes=5 \
  --version=1.17 \
  --region=us-east-1 \
  --node-type t3.xlarge \
  --zones=us-east-1a,us-east-1b,us-east-1d
```

### Stopping `eks`
```bash
$ eksctl delete cluster \
  --name=jconf-2020 \
  --region=us-east-1
```

## Minikube Deployment

### Installing dependencies

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (needed for `minikube`)
```bash
$ brew install gettext
$ brew cask reinstall virtualbox minikube
$ brew install kubectl
```

### Starting `minikube`

This will take a few minutes.
```bash
$ minikube start --cpus 7 --memory 8192
```

### Stopping `minikube`
```bash
$ minikube stop
```

### Monitoring `minikube`
```bash
$ minikuke dashboard
```

### Caching spark and zeppelin docker images in `minikube`
```bash
$ minikube cache add eschizoid/spark:3:0.0
$ minikube cache add eschizoid/spark-py:3.0.0
$ minikube cache add eschizoid/spark-r:3.0.0
$ minikube cache add eschizoid/zeppelin:0.9.0-preview1
```

## Building `Sparks` jobs
```bash
$ ./bin/build.sh
```

## Building `docker` images
Make sure you have an account with [Docker](https://hub.docker.com).
[Log in](https://docs.docker.com/engine/reference/commandline/login/) to docker 
```bash
$ ./bin/build_docker_images.sh
```

## Create roles required for `K8s` and `Spark` (`minikube` or `eks`)
```bash
$ ./bin/apply_manifests.sh
```

## Submitting spark jobs to `K8s` cluster (`minikube` or `eks`)

### Twitter Producer (`python`)
```bash
$ ./bin/run_producer.sh
```

### Spark Consumer (`python`)
```bash
$ ./bin/run_consumer.sh
```

### Spark Transformer (`scala`)
```bash
$ ./bin/run_transformer
```

### Spark Aggregator (`R`)
```bash
$ ./bin/run_aggregator
```

### Spark Visualizer (`notebook`)
```bash
$ ./bin/run_visualizer.sh
```
