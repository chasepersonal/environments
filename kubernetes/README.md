# Kubernetes

This repository will contain all the necessary files to perform Kubernetes installations on cloud platforms. This not only includes managed Kubernetes services on Cloud Providers (like EKS on AWS), but will also include non-cloud provider installs like installing k3s on a Raspberry Pi cluster.

As such, the following items will be included in this directory depending on the build type:

## k3s

k3s is a lightweight Kubernetes installation from the Rancher team that is mean to run on infrastructure with limited resources.

With the lightweight nature of k3s, multiple installs of k3s environments on both cloud providers and bare metal will be provided.

While these can support production loads, the installs that will be listed in this repository will be geared towards test and Edge cases.

More about k3s can be found on Rancher's official site:

https://rancher.com/docs/k3s/latest/en/

## MetalLB

MetalLB provides a network load balancer option for clusters that do not have this option natively. While many cloud providers provide API connections with Kubernetes to assign the Service object type of "LoadBalancer", this type is not native to bare metal implementations. If a LoadBalancer type cannot be configured natively, this restricts the implementation of Ingress routers for serving applications.

In this repository, MetalLB will be primarily used in the k3s-raspberrypi builds as the cloud provider builds will provide this functionality.

More information about MetalLB can be found here

https://metallb.universe.tf/concepts/

## Contour

Contour provides Kubernetes clusters an Envoy based Ingress controller that provides HTTP proxies and Custom Resource Definitions that make it easier to deploy applications to the web. It also supports dynamic configuration of updates that allow configuration changes without restarting the load balancer or the pods associated with it. This makes it easier to perform blue-green deployments of applications.

Contour will be used as the default Ingress controller in all the builds within this directory.

More information about Contour can be found here:

https://projectcontour.io/

## Rook/Ceph

Rook and Ceph is slowly become the defacto standard for implementing a distributed storage system on Kubernetes.

Ceph provides the storage type and distribution offers while Rook manages the placement and allocation of the storage.

Rook has other storage plugins, but Ceph tends to be the most common as it is durable, customizable, and easy to use.

This will be used as the storage standard on all builds in this directory.

More information on Rook can be found here:

https://rook.io/docs/rook/v1.2/

More information on Ceph can be found here:

https://ceph.io/

## Other Links

Outside the links provided, the following were also used to help in the setup of the Kubernetes deployments in this directory:

https://www.definit.co.uk/2019/08/lab-guide-kubernetes-load-balancer-and-ingress-with-metallb-and-contour/

https://rancher.com/docs/k3s/latest/en/quick-start/

https://docs.ansible.com/

https://www.terraform.io/docs/index.html

https://medium.com/@fdeantoni/running-rook-with-k3s-5e2c79159eaf

https://blog.raveland.org/post/raspian_ceph_en/

https://github.com/BenchLabs/blog-k8s-kops-terraform/blob/master/terraform/main.tf