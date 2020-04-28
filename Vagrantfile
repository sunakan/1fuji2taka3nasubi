# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.box = 'bento/ubuntu-18.04'
  config.vm.box = './packer/builds/debian-10.3.virtualbox.box'
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder './ansible', '/home/vagrant/ansible',
    create: true, type: :rsync, owner: :vagrant, group: :vagrant,
    rsync__exclude: [
      '*.swp',
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
      #vb.memory = 1024 * 10
    end
  end

  config.vm.define :kisaragi do |machine|
    host_name = ENV['KISARAGI_HOST_NAME'] || 'kisaragi'
    ip        = ENV['KISARAGI_IP'] || '192.168.33.12'
    machine.vm.hostname = host_name
    machine.vm.network 'private_network', ip: ip
    machine.vm.provider :virtualbox do |vb|
      vb.name = host_name
    end
  end

  config.vm.define :yayoi do |machine|
    host_name = ENV['YAYOI_HOST_NAME'] || 'yayoi'
    ip        = ENV['YAYOI_IP'] || '192.168.33.13'
    machine.vm.hostname = host_name
    machine.vm.network 'private_network', ip: ip
    machine.vm.provider :virtualbox do |vb|
      vb.name = host_name
    end

    #machine.vm.synced_folder './tmp/works/', '/home/vagrant/works/',
    #  create: true, type: :smb
  end

  config.vm.provision :hosts, :sync_hosts => true
  config.vm.provision 'ansible_local' do |ansible|
    ansible.playbook       = '/home/vagrant/ansible/main.yml'
    ansible.inventory_path = '/home/vagrant/ansible/inventories/hosts'
    ansible.version        = 'latest'
    ansible.limit          = 'my-hosts'
    ansible.verbose        = false # デバッグしない
    ansible.install        = true  # Ansibleを自動インストールする
  end
end
