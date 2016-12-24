# image name: kadriansyah/ubuntu_14_04_redis:v1
FROM ubuntu:14.04
MAINTAINER Kiagus Arief Adriansyah <kadriansyah@gmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# creating user grumpycat
RUN useradd -ms /bin/bash grumpycat
RUN gpasswd -a grumpycat sudo

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# su as grumpycat
USER grumpycat
WORKDIR /home/grumpycat

# Add Public Key to New Remote User
RUN mkdir .ssh && chmod 700 .ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfji/gkqLV5YAC2UFuE4OK3XeGtCGzWdRUYpByVVk4MHiVseLq2gmi5MN+A8k6a4xYX4knse2Ps94Md4WfcA2dHjykLs5vqmK+CqLa+OI7Ls4C9LmY/S0RgQz+Fq4WO28vVwDjje3yG+1q5mP42y45sR5i9U0sF4KOVXI+gsysOZqJPmKEFBuFYrM7qxrMMj2raKw00Mqfw0e9o/n+5ycl/YPr7gN9OqzDAmI0Wkr1441zjpk7ygrjsW7tSKeP0HXRCb8yeE0rLXEmhO1HVa7NEzkCEknZT9GlqkxM1ZcBFZszOCsy2x2ZRuIcccFNYUDhdKAgv0xJNOyqpl3tvxPN kadriansyah@192.168.1.7" > /home/grumpycat/.ssh/authorized_keys
RUN chmod 600 .ssh/authorized_keys

# configure sshd
RUN sudo apt-get update && sudo apt-get install -y openssh-server
RUN sudo sed -i 's/Port 22/Port 3006/' /etc/ssh/sshd_config
RUN sudo sed -i 's/PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config

# install wget
RUN sudo apt-get update && sudo apt-get install -y wget

# Configure NTP Synchronization, htop, git, curl
RUN sudo apt-get update && sudo apt-get install -y ntp && sudo apt-get install -y htop && sudo apt-get install -y git && sudo apt-get install -y curl libcurl3 libcurl3-dev

# Installing Redis
RUN sudo apt-get install -y gcc
RUN sudo apt-get update && sudo apt-get install -y build-essential && sudo apt-get install -y tcl8.5
RUN wget http://download.redis.io/releases/redis-stable.tar.gz
RUN tar xvzf redis-stable.tar.gz
RUN cd redis-stable && make && sudo make install && cd utils && sudo ./install_server.sh
RUN sudo rm -rf /var/run/redis_6379.pid

COPY start_script.sh /home/grumpycat/
RUN sudo chown grumpycat.grumpycat /home/grumpycat/start_script.sh && sudo chmod 755 /home/grumpycat/start_script.sh
RUN echo 'export TERM=xterm' >> ~/.bashrc

# Expose port 6379 from the container to the host
EXPOSE 6379
ENTRYPOINT ["./start_script.sh"]
