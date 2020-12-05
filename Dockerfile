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

RUN pip3 install -y ansible
# RUN set -o pipefail && wget -O - https://some.site | wc -l > /number