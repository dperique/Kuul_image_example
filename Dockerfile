# This example container is just ubuntu with ssh and some sample scripts.
#
FROM ubuntu:16.04

RUN apt-get update

# Install whatever tools you like.
#
RUN apt-get install -y vim inetutils-ping git tcpdump psmisc sudo curl net-tools

# I install ssh so I can login and do general things; just be careful about exposing
# the ssh port to the outside world.
#
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:somecrazypass' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

USER ubuntu
WORKDIR /home/ubuntu
RUN mkdir periodics
ADD print_stuff.sh
ADD print_more.sh

USER root
RUN echo 'ubuntu:somecrazypass' | chpasswd
RUN adduser ubuntu sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
