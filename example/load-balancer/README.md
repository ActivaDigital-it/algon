# Loadbalancer

For HA setup of your Algorand node load-balanced config see value file [load-balancer](values.yaml):

```shell
minikube start --vm=true --memory=4g --nodes=2
```

```shell
helm upgrade --install algon algon/algon --namespace algon -f ./example/load-balancer/values.yaml
```
