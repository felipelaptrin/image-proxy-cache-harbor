# image-proxy-cache-harbor

This is a demo repository to support my [Image proxy cache using Harbor](https://felipetrindade.com/proxy-cache-harbor/) blog post. The idea is to use Harbor to proxy-cache images and reduce calls to DockerHub.

## Running this demo

Make sure you have [devbox](https://github.com/jetify-com/devbox) and docker installed.

1) Create a Docker network for the Kind cluster

```sh
docker network create --subnet 172.100.0.0/16 custom-kind-network
```

2) Install dependencies

```sh
devbox run init
```

This will create a Kind cluster, and install Metallb, Ingress NGINX and Harbor. This will take a few minutes because it waits for all these tools to get ready.

3) Configure Harbor project

```sh
devbox run proxy-cache
```

4) Create Kubernetes secrets for registry credentials

```sh
kubectl create secret -n default docker-registry regcred-harbor \
  --docker-server=harbor.ingress.local \
  --docker-username=admin \
  --docker-password=admin
```

5) Allow insecure registries

SSH into the Kubernetes node

```sh
docker exec -it kind-worker bash
```

Then run

```sh
apt-get update
apt install vim -y
vim /etc/containerd/config.toml
```

Add the following lines to the file

```toml
[plugins."io.containerd.grpc.v1.cri".registry]
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.ingress.local"]
    endpoint = ["https://harbor.ingress.local"]
  [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.ingress.local".tls]
    insecure_skip_verify = true
[plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.ingress.local".auth]
  username = "admin"
  password = "admin"
```

Finally restart containerd

```sh
systemctl restart containerd
exit
```

6) Deploy an application that uses Kustomize

```sh
devbox run app-with-kustomize
```

7) Deploy an application that uses Helm Chart

```sh
devbox run app-with-helm
```

8) Add Harbor URL to /etc/hosts

```sh
INGRESS_LB_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "$INGRESS_LB_IP harbor.ingress.local" | sudo tee -a /etc/hosts
```

9) Access Harbor UI

Access `https://harbor.ingress.local` and use `admin` as username and `admin` as password. Notice that a project called `proxy_cache` was created and have 2 repositories caches.

10) Destroy everything

```sh
devbox run destroy
```