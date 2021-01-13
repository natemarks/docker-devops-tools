# Contributing


## How this image is  published

** 'latest' should never be consumed by production pipelines. It's only used for tests **

1) The master branch is protected. It has to be carefully, manually version bumped or we risk deploying immature changes to production pipelines.The pipeline for the master branch does the following:
    - build and publish the image to ECR
    - tags the image with the project semver. The project owner can manually assign the 'stable' tag. This should be safe to consume from production pipelines
2) The dev branch is not protected and all contributors should push to it, but try to keep the log clean. The pipeline for the dev branch does the following:
    - build and publish the image to ECR
    - tags the image with 'latest' and '[COMMIT HASH]'
   
TODO: make one or more release pipelines that kick off after a dev build that runs integration tests using latest. An engineer working on a new feature can create a pipeline that test it using either latest or [COMMIT HASH]



To get started, clone/pull the project, checkout the dev branch and run the local_build target. This will:
 - run all the local pre-build linting
 - run the pre-build tests in test_pre_build.py
 - build the container locally with the tags 'latest' and the git commit hash:
```shell
docker images | grep devops-tools
devops-tools                                695ab2db616d      7a8bc06a3e50   9 days ago     1.41GB
devops-tools                                latest            7a8bc06a3e50   9 days ago     1.41GB
```
 - finally, run test_post_build.py which uses the image to make sure allthe tools in the image work

## Making changes

Create a working branch from dev

Iterate on it using 'make local_build' frequently to build and test locally. If you add new featuers to the iage, be sure to add some test for it

When you've done as much as you can do locally, merge your branch into dev and push it. the div pipeline will  build the dev image and publish  it to ECR using the 'latest' tag and a commit hash tag.

if your working branch is "add_some_command"
```shell
git checkout dev
git pull --ff-only
git merge --squash add_some_command
git commit -am 'adding some command to the image'
git push origin dev
```


## Release a new version

The most important step is the version bump. If you skip it, we might overwrite an existing version

First figure out if the version bump will be major/minor/patch

Create a release branch from master. make sure the release brach name begins with 'release' so the dev pipeline picks it up

Merge in whatever commits you want from dev and use 'make local_build' to validate them
If the release branch is 'release_20200202'


```shell
git checkout master
git pull
git checkout -b release_2020_02_03

# merge in your changes from dev
# tst them lcallly with 
make local_build
```
Once you're happy with the local tests, bump the version. Note the commit id. it'll be used as the tag in ECR
```shell
# for a patch bump
make part=patch bump
# for a minor bump
make part=minor bump
# for a major bump
make part=major bump

git push origin release_20200202
```

Once the release branch is pushed, the pipeline will build ECR image with the commit ID. Use the newly published image tot test it in pipelines

Finally issuse a pull request for the release branch 
zzz