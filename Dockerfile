FROM ubuntu:20.04
LABEL maintainer="npmarks@gmail.com"
RUN apt-get update && \
  apt-get install -y software-properties-common curl && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - &&\
  apt-add-repository \
  "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" \
  && apt-get install --no-install-recommends --yes \
  python3 python3-pip \
  packer \
  terraform \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible
# RUN set -o pipefail && wget -O - https://some.site | wc -l > /number
RUN curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/v0.26.7/terragrunt_linux_amd64 \
  --output /usr/local/bin/terragrunt && chmod 755 /usr/local/bin/terragrunt