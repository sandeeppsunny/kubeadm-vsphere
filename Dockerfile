FROM ubuntu:16.04
ENV TZ 'America/Los_Angeles'
    RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

ENV GOVERSION 1.12.6
ENV GOROOT /opt/go
ENV GOPATH /root/.go

RUN apt-get update
RUN apt-get install -y openssh-server git make curl uuid-runtime genisoimage net-tools binfmt-support vim expect ssh python python-pip unzip
RUN apt-get clean

RUN cd /opt && wget https://get.docker.com/builds/Linux/x86_64/docker-1.13.1.tgz && \
    tar zxf docker-1.13.1.tgz && rm docker-1.13.1.tgz && \
    chmod +x /opt/docker/docker && \
    ln -s /opt/docker/docker /usr/bin/

RUN cd /opt && wget https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz && \
    tar zxf go${GOVERSION}.linux-amd64.tar.gz && rm go${GOVERSION}.linux-amd64.tar.gz && \
    ln -s /opt/go/bin/go /usr/bin/ && \
    mkdir $GOPATH

RUN go get github.com/vmware/govmomi/govc && \
    ln -s /root/.go/bin/govc /usr/bin

RUN cd /root && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/bin/

RUN mkdir -p /root/.ssh && cd ~/.ssh && wget http://pa-dbc1110.eng.vmware.com/sandeepsunny/ssh-pair/id_rsa && \
    chmod 600 id_rsa

RUN cd ~/.ssh && wget http://pa-dbc1110.eng.vmware.com/sandeepsunny/ssh-pair/id_rsa.pub

RUN apt install software-properties-common -y 

RUN apt-add-repository ppa:ansible/ansible && apt-get update

RUN apt install ansible -y

ADD govcscript.sh /govcscript.sh

ADD master-playbook.yaml /master-playbook.yaml

ADD vsphere.conf.template /vsphere.conf.template

ADD master-config.yaml /master-config.yaml

ENTRYPOINT ["bash","/govcscript.sh"]
