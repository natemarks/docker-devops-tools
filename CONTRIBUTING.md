# Contributing
Every time the default branch is pushed, the azure pipelines pick it up and test the build. If the tests pass, the image is pushed to the sandbox ECR and tagged with the commit id.

TO consume a new image in a pipeline, bump the version  and upload the versioned image to the target ECR
```bash
make part=patch bump
make AWS_ACCOUNT_ID=01234567890 upload_release_images
```
