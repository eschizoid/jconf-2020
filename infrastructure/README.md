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
    --name=chicago-cloud-conference-2019 \
    --nodes=5 \
    --version=1.12 \
    --region=us-east-1 \
    --node-type t3.xlarge \
    --zones=us-east-1a,us-east-1b,us-east-1d
```

### Configure `eks` cluster
Unfortunately logging and vpc configuration for `eks` clusters cannot be done using `eksctl`. The ticket can be followed
[here](https://github.com/weaveworks/eksctl/issues/649).

```bash
$ aws eks update-cluster-config \
    --name chicago-cloud-conference-2019 \
    --region us-east-1 \
    --resources-vpc-config endpointPublicAccess=true,endpointPrivateAccess=true

$ aws eks update-cluster-config \
    --name chicago-cloud-conference-2019 \
    --region us-east-1 \
    --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```

### Stopping `eks`
```bash
$ eksctl delete cluster \
    --name=chicago-cloud-conference-2019 \
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
$ minikube cache add eschizoid/spark:2.4.3
$ minikube cache add eschizoid/spark:python
$ minikube cache add eschizoid/spark:R
$ minikube cache add eschizoid/zeppelin:0.9.0-SNAPSHOT
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
$ ./bin/run_producer.sh
```

### Spark Transformer (`scala`)
```bash
$ ./bin/run_transformer
```

### Spark Aggregator (`R`)
```bash
$ ./bin/run_aggregator
```

### Spark Visualizer (`node` / `notebook`)
```bash
$ ./bin/run_visualizer.sh
```
