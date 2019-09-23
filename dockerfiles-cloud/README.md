# Dockerfiles

The following will contain dockerfiles for each cloud environment that will specify the minimum required components for running commands within those cloud environments.

These Dockerfiles can be built from the main directory with the following command:

Windows:

`docker build -f /c/Users/<name of user>/Environments/dockerfiles-dev/<name of cloud provider>/Dockerfile -t <name of image>:<tag> .`

Linux/Mac:

`docker build -f $HOME/Environments/dockerfiles-dev/<name of cloud provider>/Dockerfile -t <name of image>:<tag> .`

Once the image is built, the project directory can be mounted in a running container with the following command:

`docker run -it -v $PWD:/tmp/environments <name of image>:<tag>`

You can also mount the Docker socket to the running container so conatiners can be built within the running container.

**NOTE:** The `/var/run/docker.sock` will need to be changed to `//var/run/docker.sock` for Windows machines.
This method might not be fully compatible with Docker Toolbox. It is recommended to use Docker for Windows for windows machines.

`docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/tmp/environments <name of image>:<tag>`

This will also ensure that the docker container can access docker on the host and use commands to build child containers