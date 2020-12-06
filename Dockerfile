# ubuntu 2020 (focal)
FROM ubuntu:focal-20201106
LABEL maintainer="npmarks@gmail.com"
RUN apt-get update && \
  apt-get install -y --no-install-recommends --yes \
  python3 python3-pip \
  packer \
  ca-certificates \
  jq \
  git \
  unzip \
  curl \
  wget \
  terraform \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible \
  pytest \
  pytest-testinfra \
  molecule \
  awscli

RUN wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip && unzip ./terraform_0.13.5_linux_amd64.zip -d /usr/local/bin/

RUN wget -q -O /usr/local/bin/kubergrunt "https://github.com/gruntwork-io/kubergrunt/releases/download/v0.6.1/kubergrunt_linux_amd64" && chmod +x /usr/local/bin/kubergrunt

RUN curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/v0.26.7/terragrunt_linux_amd64 \
  --output /usr/local/bin/terragrunt && chmod 755 /usr/local/bin/terragrunt

RUN wget https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip && unzip ./packer_1.6.5_linux_amd64.zip -d /usr/local/bin

WORKDIR /azp
CMD ["terraform" , "--version"]
