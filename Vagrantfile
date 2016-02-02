# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base box for consul servers
  config.vm.box = "bento/centos-6.7"

  # Ip of the server that will get bootstrapped
  leader_ip = "172.20.20.11"

  # Provision cluster servers in server mode
  (1..3).each do |i|
    config.vm.define "consul-server#{i}" do |consul|
      if i == 1
        ip = leader_ip
        start_cmd = "consul agent -server -bootstrap -bind=#{ip} -config-dir=/etc/consul.d > /var/log/consul.log &"
      else
        ip = "172.20.20.1#{i}"
        start_cmd = "consul agent -server -bind=#{ip} -config-dir=/etc/consul.d -retry-join=#{leader_ip} > /var/log/consul.log &"
      end

      consul.vm.hostname = "consul-server#{i}"
      consul.vm.network "private_network", ip: ip

      consul.vm.provision "shell", path: "scripts/provision.sh"
      consul.vm.provision "shell", inline: start_cmd
    end
  end

  # Provision consule client with ui
  config.vm.define "consul-client" do |client|
    ip = "172.20.20.10"
    start_cmd = "consul agent -client=#{ip} -bind=#{ip} -config-dir=/etc/consul.d -ui -retry-join=#{leader_ip} > /var/log/consul.log &"

    client.vm.hostname = "consul-client"
    client.vm.network "private_network", ip: ip

    client.vm.provision "shell", path: "scripts/provision.sh"
    client.vm.provision "shell", inline: start_cmd
  end
end
