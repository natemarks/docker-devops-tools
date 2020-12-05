This project builds a docker image with some commonly used tools. It's a just a convenient way to reproduce my pipeline context locally.

https://ubuntu.com/blog/we-reduced-our-docker-images-by-60-with-no-install-recommends

https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

The image includes:
 - terraform
 - terragrunt
 - packer
 - python3 and pip3
 - ansible
 - molecule
 - pytest and pytest-testinfra


## Usage

```shell script
docker run -it devops-tools:dev-latest terraform --version
Terraform v0.14.0

docker run -it devops-tools:dev-latest terragrunt --version
terragrunt version v0.26.7

docker run -it devops-tools:dev-latest packer --version
1.6.5

docker run -it devops-tools:dev-latest ansible --version
ansible 2.10.3
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/dist-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.8.5 (default, Jul 28 2020, 12:59:40) [GCC 9.3.0]

```