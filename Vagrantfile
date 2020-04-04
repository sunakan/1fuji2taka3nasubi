# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.synced_folder "./ansible", "/home/vagrant/ansible",
    create: true, type: :rsync, owner: :vagrant, group: :vagrant,
    rsync__exclude: [
      "*.swp",
    ]

  config.vm.provider :virtualbox do |vb|
    vb.gui    = false
    vb.memory = 1024 * 2
    vb.cpus   = 2
  end

  config.vm.define :mutsuki do |machine|
    host_name = ENV['MUTSUKI_HOST_NAME'] || 'mutsuki'
    ip        = ENV['MUTSUKI_IP'] || '192.168.33.11'
    machine.vm.hostname = host_name
    machine.vm.network 'private_network', ip: ip
    machine.vm.provider :virtualbox do |vb|
      vb.name = host_name
    end
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook       = "/home/vagrant/ansible/main.yml"
    ansible.inventory_path = "/home/vagrant/ansible/inventories/hosts"
    ansible.version        = "latest"
    ansible.limit          = "my-hosts"
    ansible.verbose        = false # デバッグしない
    ansible.install        = true  # Ansibleを自動インストールする
  end
end
