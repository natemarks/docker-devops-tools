# Contributing


## How this image is  published

** 'latest' should never be consumed by production pipelines. It's only used for tests **

1) The master branch is protected. It has to be carefully, manually version bumped or we risk deploying immature changes to production pipelines.The pipeline for the master branch does the following:
    - build and publish the image to ECR
    - tags the image with the project semver. The project owner can manually assign the 'stable' tag. This should be safe to consume from production pipelines
2) The dev branch is not protected and all contributors should push to it, but try to keep the log clean. The pipeline for the dev branch does the following:
    - build and publish the image to ECR
    - tags the image with 'latest' and '[COMMIT HASH]'
   
There should be one or more release pipeline that kicks off after a dev build that runs integration tests using latest. An engineer working on a new feature can create a pipeline that test it using either latest or [COMMIT HASH]



To get started, clone/pull the project and run the local_build target. This will:
 - run all the local pre-build linting
 - run the pre-build tests in test_pre_build.py
 - build the container locally with the tags 'latest' and the git commit hash:
```shell
docker images | grep devops-tools
devops-tools                                695ab2db616d      7a8bc06a3e50   9 days ago     1.41GB
devops-tools                                latest            7a8bc06a3e50   9 days ago     1.41GB
```
 - finally, run test_post_build.py which uses the image to make sure allthe tools in the image work


To make a change, first create a branch for your changes.  Use  the test and local_build to iterate on it until you're happy with it. 

## Publishing the image

When the image is passing all the manual and automatic local tests you can think of, it's time to publish the image to ECR so you can test it in some pipelines. The worst thing that can happen is also the easiest: if  you merge your changes into the master branch, The image will  be published with the tag of the current releases version which would immediately deploy it to all the production pipelines. bad.

**Squash your branch and edit the commit message to clearly describe your changes**

## Accepting the PR

The change has to be bumped before being merged into the master branch
## Bump the version
TODO: use somthing like this to automate version bumps during pull requests: https://github.com/marketplace/actions/bumpr-bump-version-when-merging-pull-request-with-specific-labels

For no
Push the branch and use it to create a pull request. When  the PR is accepted, the pipeline will l build and push the new image
This project creataes a docker image wiht a bundle of devops tools to use locally and in pipelines. It makes the pipeline steps simpler by removing the need to install and configure tools. It makes troubleshootng pipeline problems easier by allowing us to test the pipeline commands and configs locally.

If you add some new functionality (a program, for example), please add a test that verifies the change in the container. For example, I try to run all the docker commands in test_post_build.py


  


Assuming that works, build the  docker image locally and run the post build tests:
```
make local_build
```