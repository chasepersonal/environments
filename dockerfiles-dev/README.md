# Dockerfiles

The following will contain dockerfiles for each cloud environment that will specify the minimum required components for running commands within those cloud environments.

These Dockerfiles can be built from the main directory with the following command:

`docker build -f Environments/dockerfiles-dev/<name of cloud provider/Dockerfile -t <name of image>:<tag> .`

Once the image is built, the project directory can be mounted in a running container with the following command:

`docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/tmp/environments <name of image>:<tag>`

This will also ensure that the docker container can access docker on the host and use commands to build child containers