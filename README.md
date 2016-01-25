# README #

This repository contains files for provisioning a Consul cluster using Vagrant. The cluster is intended for use as part of development or testing and allows you to run a cluster of 3 Consul servers plus a Consul client which runs the Consul Web UI.

Much of the content was derived from a blog post by Justin Ellingwood, [How to Configure Consul in a Production Environment on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-configure-consul-in-a-production-environment-on-ubuntu-14-04). There are diffences between Justin's implementation and that given here with the key difference being that Vagrant is used to provision the cluster. The virtual machines are also based on the `hashicorp/precise64` box, a packaged standard Ubuntu 12.04 LTS 64-bit box.

## Overview ##

For an overview of what's been done here please refer to the following blog posts:

* [Setting up a Consul cluster for testing and development with Vagrant (Part 1)](http://www.andyfrench.info/2015/08/setting-up-consul-cluster-for-testing.html)
* [Setting up a Consul cluster for testing and development with Vagrant (Part 2)](http://www.andyfrench.info/2015/08/setting-up-consul-cluster-for-testing_15.html)

## Prerequisites ##

You will need to have installed Vagrant and VirtualBox.

## Usage ##

Once you have downloaded the files open a command prompt and change to the directory containing the Vagrantfile. To start the bootstrap server type the following:

`vagrant up consul1`

Thereafter you can start the other 2 servers:

    vagrant up consul2
    vagrant up consul3

The client instance is started in much the same way:

`vagrant up consulclient`

For full details please refer to the blog posts mentioned above.

### Accessing the Consul Web UI ###

Once the cluster is up-and-running you will be able to access the Consul Web UI from a browser running on your host workstation by going to the following URL: [http://172.20.20.40:8500/ui/](http://http://172.20.20.40:8500/ui/).