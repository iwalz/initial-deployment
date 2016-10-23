initial-deployment
==================

This docker container is build for executing bash scripts that mainly interact with kubectl.
It asumes, that you have a git repository that contains a bash script and kubernetes yaml/json files.
I use it to automate the initial deployment of my applications in a new kubernetes environment.


How to run this container
-------------------------

To run this container from dockerhub, use this command:

```bash
docker run -v /root/.ssh/id_rsa:/root/.ssh/id_rsa -v /home/core/.kube/config:/root/.kube/config iwalz/initial-deployment --servers=3 --script="deploy.sh deploy" --repository=git@github.com:example/k8s-manifests.git
```

The ssh key from `/root/.ssh/id_rsa` is used to clone the `--repository=git@github.com:iwalz/k8s-manifests.git` and executes `deploy.sh deploy` from this repository once 3 servers reached the Ready state - periodically checked via `kubectl get no`.

Although this container is based on the alpine image, it contains a fully functional bash. Mainly to benefit from a lot of scripting sugar that exists in bash but not in sh.

Configure kubectl
-----------------

As you saw in the previous example, we've mounted a kubectl config to `/root/.kube/config` - this file contains all information that kubectl needs to connect to the apiservers.
These are the basic commands to configure your endpoint:

```bash
kubectl config set-cluster mycluster --server=http://apiserver-production.example.com:8080
kubectl config set-context mycontext --cluster=mycluster
kubectl config use-context mycontext
```

Or if you're using username and password alternativly:

```bash
kubectl config set-credentials kubeuser --username=kubeuser --password=kubepassword
kubectl config set-context mycontext --cluster=mycluster --user=kubeuser
```

How should the upstream repository look like?
---------------------------------------------

To manage the all the yaml files for kubernetes, I personally prefer to keep everything in a structured git repository. Because the content of my kubernetes cluster grows and grows every day, I typically place a small bash scripts into the manifests repository to interact with my cluster and deploy all the kubernetes deployments and services.

To prevent CrashLoopBackOffs because of dependent services, I typically achieve kind of ordering on the root folder level and on the filenames in the subdirectories. 

Exactly for this use case, I use this container. It just clones a git repository and executes the scripts in there.

```bash
platform/
  01-secrets.yaml
  02-kubernetes-dashboard.yaml
services/
  01-example.yaml
applications/
  01-example.yaml
deploy.sh
```

You can use all the cool bash features from within the container, like:

```bash
#!/bin/bash
shopt -s globstar

echo "Deploying applications"
for f in ./applications/*.yaml; do
	echo "$f"
	/usr/bin/kubectl create -f "$f"
done
```