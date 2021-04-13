# ubuntu 2020 (focal)
FROM ubuntu:focal-20201106
LABEL maintainer="npmarks@gmail.com"
RUN apt-get update && \
  apt-get install -y --no-install-recommends --yes \
  python3 python3-pip \
  packer \
  ca-certificates \
  jq \
  less \
  vim \
  git \
  unzip \
  curl \
  wget \
  golang \
  openssh-server \
  shellcheck \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.ssh
COPY ssh/config /root/.ssh
RUN chmod 644 /root/.ssh/config

COPY requirements.txt /requirements.txt

RUN pip3 install -r /requirements.txt

# set python 3 as the default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
  && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

RUN wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip && unzip ./terraform_0.13.5_linux_amd64.zip -d /usr/local/bin/

RUN wget -q -O /usr/local/bin/kubergrunt "https://github.com/gruntwork-io/kubergrunt/releases/download/v0.6.1/kubergrunt_linux_amd64" && chmod +x /usr/local/bin/kubergrunt

RUN curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/v0.26.7/terragrunt_linux_amd64 \
  --output /usr/local/bin/terragrunt && chmod 755 /usr/local/bin/terragrunt

RUN curl -fsSL https://raw.githubusercontent.com/natemarks/git_cache_repo/main/mirror_repo.sh?ref=v0.0.2 \
  --output /usr/local/bin/mirror_repo.sh && chmod 755 /usr/local/bin/mirror_repo.sh

RUN wget https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip && unzip ./packer_1.6.5_linux_amd64.zip -d /usr/local/bin

COPY scripts /scripts
RUN chmod -R 755 /scripts
COPY ansible/ /etc/ansible/

COPY cache_clone /usr/local/bin
RUN chmod 755 /usr/local/bin/cache_clone

WORKDIR /azp
CMD ["terraform" , "--version"]
