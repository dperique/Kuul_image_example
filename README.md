# Kuul Image Example

The repo shows an example docker image to run on the
[Kuul Periodic System](https://github.com/dperique/Kuul_periodics).

NOTE: Remember, the Kuul Periodic System is just a k8s cluster running your Kuul jobs; remember
that Kuul jobs are just Kubernetes CronJubs.

This is a docker image that can be run as a plain docker image in case you need to debug it
before deploying it onto your Kuul Periodic System.

Here's how to build the Kuul Image example that does something simple (i.e., print a message to
the screen, ping something on the Internet).

You can build the image using the `Dockerfile` in this repo and push it to your docker registry
or just use the copy of my image on docker.io (the template.yaml in this repo uses it to help you
get started).

```
# Build the image using the tag "v3" for example.
#
docker build -t example_kuul_image:v3 .

# Run container build from the image as a daemon.
#
docker run --name mycont -d example_kuul_image:v3 sh -c "./print_stuff.sh some_string"

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

# If your user name is "myusername" do this and your image will be pushed to
# docker.io:
#
docker login (and then enter your docker.io credentials)
docker build -t myusername/example_kuul_image:v3 .
docker push myusername/example_kuul_image:v3
```

Here's some sample output:

```
$ docker run --name mycont -d example_kuul_image:v3 sh -c "./print_stuff.sh some_string"
3dcce474314b306eb8adde38f87946c9b950d4773d72ab13951d2f9c57e7c4e3

$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS               NAMES
3dcce474314b        example_kuul_image:v3   "sh -c './print_stuf…"   3 seconds ago       Up 2 seconds                            mycont

$ docker logs 3dcce474314b
This script will do stuff
  and print stuff
I can ping something on the Internet
+ echo 'I can ping something on the Internet'
+ ping -c 5 www.google.com
PING www.google.com (172.217.2.4): 56 data bytes
64 bytes from 172.217.2.4: icmp_seq=0 ttl=37 time=69.409 ms
64 bytes from 172.217.2.4: icmp_seq=1 ttl=37 time=69.547 ms
64 bytes from 172.217.2.4: icmp_seq=2 ttl=37 time=68.096 ms
64 bytes from 172.217.2.4: icmp_seq=3 ttl=37 time=64.687 ms
64 bytes from 172.217.2.4: icmp_seq=4 ttl=37 time=63.601 ms
--- www.google.com ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max/stddev = 63.601/67.068/69.547/2.465 ms
+ set +x
```

## Run the image on Kuul k8s cluster cluster

Create and `kubectl apply ...` your Kubernetes CronJobs using the sample `template.yaml` file in this
repo, run it on any k8s cluster and debug it.  Once it's ready, you can then add it to your Kuul
k8s cluster.

In my case, I have a `make.sh` file (in this repo) that I can use to make different CronJobs.  I run
`make.sh` and generate two Kubernetes CronJob yaml files.  After that, I can `kubectl apply -f ...`
them as needed.  I show an example of applying one of them below.

The yamls should load and you should see CronJobs via `kubectl get cronjob`.

```
$ kubectl apply -f pjob1-staging1.yaml
cronjob "job1-staging" created

$ kubectl get cronjob
NAME              KIND
job1-staging      CronJob.v1beta1.batch

$ kubectl get cronjob job1-staging
NAME              SCHEDULE     SUSPEND   ACTIVE    LAST SCHEDULE   AGE
job1-staging      15 * * * *   False     0         <none>          10s
job2-staging      30 * * * *   False     0         <none>          3s
...
```

After a job runs, you'll see the "LAST SCHEDULE" field change.

Eventually, your job will run and you will see this.  You can then get the logs.

```
$ kubectl get po -a |grep job1
job1-staging-1553461740-xt89f      0/1       Completed   0          1m

$ kubectl logs job1-staging-1553461740-xt89f
This script will do stuff
  and print stuff
I can ping something on the Internet
+ echo 'I can ping something on the Internet'
+ ping -c 5 www.google.com
PING www.google.com (172.217.6.164): 56 data bytes
64 bytes from 172.217.6.164: icmp_seq=0 ttl=53 time=1.164 ms
64 bytes from 172.217.6.164: icmp_seq=1 ttl=53 time=1.140 ms
64 bytes from 172.217.6.164: icmp_seq=2 ttl=53 time=1.127 ms
64 bytes from 172.217.6.164: icmp_seq=3 ttl=53 time=1.151 ms
64 bytes from 172.217.6.164: icmp_seq=4 ttl=53 time=1.090 ms
--- www.google.com ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max/stddev = 1.090/1.134/1.164/0.025 ms
Then I can print my first parameter: staging1
+ set +x
```

NOTES:

* If you don't have a docker registry, you can build the docker image on one of your
  k8s nodes so that the image is already in the docker instance running on that node.
  You will have to use a nodeSelector to get your Pod to run on the node that has your
  image.
* If your image is already built, you can use the docker save/load commands to add your
  image to a k8s node directly:
    * Run `docker save -o ~/my-image.tgz kuul:v3` on the machine where you built your
      docker image
    * Run `docker load -i my-image.tgz` on one of your k8s nodes
* If you use one of these methods, you will have to modify your template.yaml so that
  the image is fetched from the k8s node and not a docker registry.


## Example of how to use a Kuul Image

My use-case is to run a periodic set of regression tests on some software our team deployed.
I created a Kuul image for running those tests and use a `make.sh` file for creating differnt
template.yaml files for running those tests on different environments we use for staging and
production.

The flow is like this:

* Run the regression test, upload the logs to a log server and get a link.
* Get a pass/fail status and report it into a slack channel including the log link
* Runs the jobs every 20 minutes and retain 2 previous jobs so I can quickly view the
  logs of the last 2 times a job ran.
* Use [k9s](https://github.com/derailed/k9s) to view the CronJobs and view the logs
