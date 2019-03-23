# Kuul_image_example

The repo shows an example docker image to run on the
[Kuul Periodic System](https://github.com/dperique/Kuul_periodics).

It is just a docker image so it can also be run standalone -- but that's part of
the point -- i.e., you want to be able to run it standalone so you can debug it
before adding it to a Kuul Periodic System.

Here's how you can build your own Kuul Image to do something simple (i.e., print a message to
the screen).

* Make sure you have docker installed
* Create your Dockerfile
  * In the example Docker file, we have a ubuntu 16.04 container with user=ubuntu
    and in the `/home/ubuntu/periodics`, we have some scripts:
    * print_stuff.sh
    * print_more.sh

```
# Build the image using the tag "v3" for example.
#
docker build -t kuul:v3 .

# Run container build from the image as a daemon.
#
docker run --name mycont -d kuul:v3

# Check the logs to see if it did the right thing.
#
docker logs mycont

# Stop any container using the image (if there is one).
#
docker ps -a
docker stop ...

# Remove the container to cleanup.
#
docker rm ...

# Remove the image if you don't want it anymore.
#
docker rmi ...

# If your container is not doing what you want, debug, and repeat the
# above.

# Once satisfied with your container, push it to your docker registry.
# I use my.docker-registry.com as an example.
#
docker build -t my.docker-registry.com/kuul:v3 .
docker push my.docker-registry.com/kuul:v3
```

## Debugging the image on Kubernetes

Build your Kubernetes CronJob using the sample template.yaml file in this repo, run it
on any k8s cluster and debug it.  Once it's ready, you can then add it to your Kuul k8s cluster.

NOTES:

* If you don't have a docker registry, you can build the docker image on one of your
  k8s nodes so that the image is already in the docker instance running on that node.
  You will have to use a nodeSelector to get your Pod run on the node that has your
  image.
* If your image is already built, you can use the docker save/load commands to add your
  image to a k8s node directly:
    * Run `docker save -o ~/my-image.tgz kuul:v3` on the machine where you built your
      docker image
    * Run `docker load -i my-image.tgz` on one of your k8s nodes
* If you use one of these methods, you will have to modify your template.yaml so that
  the image is fetched from the node and not a docker registry.
