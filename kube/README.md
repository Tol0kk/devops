# How to run the project using minikube

This documentation is for deploying the project using minikube (local kubernetes cluster).

# Prerequisites
- [minikube](https://minikube.sigs.k8s.io/docs/start/) to create the cluster and run the docker images
- [nix](https://nixos.org/download.html) to build the images

# Drawback

This does not expose any other services than a nginx gateways to the services. So for developement this will not be highly useful. Since you can't access the services from outside the cluster (database, frontend, backend).
It also force some domain name inside the project configuration like (frontend, backend, mysql, etherpad). So in a developement environment you will need to change the domain or use a proxy like nginx to redirect the traffic to the correct service or dns reddirect.

# Starting using minikube
```sh
# Start minikube cluster
minikube start

# Start metric server to get information on the clusters
minikube addons enable metrics-server

# Launch minikube GUI 
minikube dashboard
```

# Import Images
There is a imagePullPolicy: Never in the deployment yaml. So we need to load the images manually.

```sh
# Load minkube docker env
eval $(minikube docker-env)

# Build doodle frontend image
nix build nix/.#doodle-front-docker
# Push doodle front docker image
docker load < result

# Build doodle backend image
nix build nix/.#doodle-api-docker
# Push doodle api docker image
docker load < result
```

# Deploy yamls

```sh
# Create namespace
minikube kubectl -- create namespace doodle

# Create etherpad secrets
minikube kubectl -- create secret generic etherpad-apikey \
        --from-file=APIKEY.txt=nix/doodle/api/APIKEY.txt \
        -n doodle

# Add etherpad service/deployment
minikube kubectl -- apply -f kube/etherpad.yaml

# Add mysql service/deployment
minikube kubectl -- apply -f kube/mysql.yaml

# Add frontend service/deployment
minikube kubectl -- apply -f kube/doodle-frontend.yaml

# Add backend service/deployment
minikube kubectl -- apply -f kube/doodle-api.yaml

# Add cert-manager & nginx
# minikube kubectl -- apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml # Need to wait for cert-manager to be ready
# minikube kubectl -- apply -f kube/cert-manager.yaml
minikube kubectl -- apply -f kube/nginx.yaml
```

# Cleanup

```sh
minikube stop
minikube delete 
```