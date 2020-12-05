FROM ubuntu:20.04
LABEL maintainer="npmarks@gmail.com"
RUN sudo apt-add-repository \
  "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" \
  && apt-get update && apt-get install --no-install-recommends --yes \
  curl \
  python3 \
  packer \
  terraform \
  && rm -rf /var/lib/apt/lists/*

RUN pip install -y ansible
# RUN set -o pipefail && wget -O - https://some.site | wc -l > /number