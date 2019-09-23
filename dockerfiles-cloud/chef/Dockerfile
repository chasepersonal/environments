FROM debian:stretch-slim

RUN apt-get update && apt-get install wget jq
RUN wget https://packages.chef.io/files/stable/chefdk/4.3.13/debian/9/chefdk_4.3.13-1_amd64.deb
RUN dpkg -i chefdk_4.3.13-1_amd64.deb
