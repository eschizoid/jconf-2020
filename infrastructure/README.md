## Infrastructure

## EKS Deployment

### Installing dependencies
```bash
$ brew aws-cli
$ brew tap weaveworks/tap
$ brew install weaveworks/tap/eksctl
```

### Starting `eks`
```bash
$ eksctl create cluster \
    --name=chicago-cloud-conference-2019 \
    --nodes=3 \
    --version=1.12 \
    --region=us-east-1 \
    --node-type t3.medium \
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

## Building `docker` images
```bash
$ cd spark
$ ./build_dockerf_images.sh
```

## Permissions for spark jobs
```bash
$ kubectl apply -n minikube -f spark-rbac.yaml
```

## Submitting spark job to `minikube`
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
