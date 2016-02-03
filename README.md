# Terraform Consul Cluster

## Introduction
This repo sets up a consul cluster that can be deployed locally with vagrant or
on google compute engine with terraform. The cluster is made up of 3 consul
servers and at least one consul client server running a very basic nginx
website. This website is monitored by consul and can be updated by altering a
key in the consul ui. consul-template running on the client server will then
restart the nginx process and reload the updated site. Any server should be able
to be restarted and rejoin the consul cluster. All provisioning is done using
ansible. This project also illustrates a development environment and production
environment can be closely mirrored by using these tools.

## Technologies used
* terraform -> setting up infrastructure on google compute engine
* vagrant -> setting up infrastructure locally
* ansible -> provisioning servers
* consul -> service monitoring and discovery
* consul-template -> updating configuration settings
* nginx -> web servers

## Requirements
1. [virtualbox](https://www.virtualbox.org/wiki/Downloads)
1. [vagrant](https://www.vagrantup.com/downloads.html)
1. [ansible](http://docs.ansible.com/ansible/intro_installation.html)
1. [terraform](https://www.terraform.io/downloads.html)

## Terraform
terraform is a tool used to automate the creation and management of cloud based
infrastructure. In this case we will be using google compute engine as our
provider. However, terraform supports an array of other [providers](https://www.terraform.io/docs/providers/index.html).
In this example we will set up a three instances behind a load balancer and two
instances on their own. We also setup the basic networking and firewall rules
for our applications.

Any commands from this section must be run from the `terraform` directory.

### Setup
1. Obtain a google compute engine account
1. Create a project in the compute engine console
1. Download an access key for the project you created
  * This should be a `json` file
1. Run `cp terraform.tfvars.example terraform.tfvars` and update the variables
  * You should only need to change `project_name` and `account_file_path`
  * `project_name` should be the id of the project you created
  * `account_file_path` should be the path to the `json` access key

### How Terraform Works
terraform will load any files with the `.tf` extension as well as
`terraform.tfstate` and `terraform.tfvars`. It will use these files to create or
apply a plan. terraform will automatically decide the order of resource creation
based on dependencies. It will also identify any cyclical dependencies and warn
you of them. All files with a `.tf` extension are merged so order is only
determined by dependencies and the order in the files.

If we look at our main file `consul.tf`, can see that there are many `${...}`.
This is how terraform interpolates variables and uses built in functions. They
are also used to determine a dependency graph and thus an execution order for
our plan.

### Using Terraform
Now that we have everything we need set up we should be able to create our
consul cluster. We can run `terraform plan` to see what changes terraform is
going to make to our infrastructure. This is a great way to see if terraform is
going to need to destroy anything that we may not want to before we do it. After
running this we should see
```
Plan: 10 to add, 0 to change, 0 to destroy.
```
Since we have nothing built yet terraform is only going to create
infrastructure. Above the final output we can actually see all the
infrastructure that terraform is planning to build! Now that we know terraform
will not do anything unexpected we can run `terraform apply`. This command will
actually start to build the infrastructure from the plan. This should take a few
minutes to complete.

Once this is done we should see something like this
```
Outputs:

  consul_client_instance_ips   = 146.2.246.180 144.127.91.32
  consul_server_instance_ips   = 102.154.62.134 104.97.51.186 14.17.18.215
  consul_server_pool_public_ip = 14.14.182.26
```
This output is defined by our `output.tf` file which pulls this data from our
recently created `terraform.tfstate` file. We can see this output at any point
by running `terraform output`.

If we run `terraform plan` again, we should get a response that says there is
nothing to do. terraform keeps track of the state of our infrastructure by
comparing the merge of all our `.tf` files to the data in `terraform.tfstate`.
So in this case there is no difference. For a production environment it is
advised to store the state file in some kind of central location so the state of
the infrastructure can remain consistent throughout a team.

If we want to take down our infrastructure we can run `terraform plan -destoroy`
to look at the destruction plan and then run it with `terraform destroy`. This
should remove everything we created from our project.

## Consul
After running `terraform apply` we should have our consul cluster up and
running. We can connect to the ui by going to
`http://<consul_server_pool_public_ip>:8500/ui/`. If we click on nodes we should
see that we have five servers. 3 running in server mode and 2 in client mode.
If we click on services we should see that we have consul and nginx running
across our instances. This gives us an over view of the health of our
application. We can add any other services we want to consul and it will monitor
them with the provided health check. In this case we are using the ansible's
consul module to add nginx to our consul cluster for monitoring. This can be
seen at the bottom of `ansible/roles/web/task/main.yml`.

We can also update our nginx servers by adding the `nginx/web_title` key to the
kv of the ui. As soon as we add this key we should see the websites change on
our client nodes. Any time this key is updated they should change. This is an
example of how we can use consul-template to update configuration files through
consul's key value store.

If any of our consul instances are restarted, they should automatically be able
to rejoin our cluster through the loadbalancer we setup for the server nodes.
This allows our cluster to be more resilient and fault tolerant. You should be
able to test this by restarting one of servers in through the google compute
engine console. The scripts to facilitate this can be seen in greater detail by
looking at the consul role.

## Vagrant
If we want to run the project locally we can just run `vagrant up`. This should
create the same setup as terraform; the only differences are there is no
loadbalancer and there is only one client server. The consul ui can be accessed
on any of the server nodes with `http://<server node ip>:8500/ui/`.
