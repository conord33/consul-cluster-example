# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base box for consul servers
  config.vm.box = "bento/centos-6.7"

  # Use insecure key
  config.ssh.insert_key = false

  N = 3
  (0..N).each do |i|
    if i == 0
      name = "consul-client"
    else
      name = "consul-server-#{i}"
    end
    config.vm.define name do |consul|
      consul.vm.network "private_network", ip: "172.20.20.1#{i}"
      consul.vm.hostname = name

      if i == N
        consul.vm.provision :ansible do |ansible|
          ansible.limit = "all"
          ansible.playbook = "ansible/consul.yml"
          ansible.inventory_path = "ansible/inventories/vagrant.yml"
          ansible.extra_vars = {
            consul_join_ip: "172.20.20.1#{i}",
            consul_server_count: N
          }
        end
      end
    end
  end
end
