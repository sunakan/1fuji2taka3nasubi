# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

VAGRANT_BOX_UBUNTU_20    = 'bento/ubuntu-20.04'
VAGRANT_BOX_UBUNTU_18    = 'bento/ubuntu-18.04'
VAGRANT_BOX_CENTOS_7     = 'bento/centos-7'
VAGRANT_BOX_AMAZONLINUX  = 'jonnangle/amazonlinux'
VAGRANT_BOX_AMAZONLINUX2 = 'bento/amazonlinux-2'
VAGRANT_BOX_DEFAULT = VAGRANT_BOX_UBUNTU_20

vm_specs = [
  { vagrant_box: VAGRANT_BOX_UBUNTU_20,    name: 'fuji-01', ip: '192.168.1.11', cpus: 2, memory: 512*6, sync_dir: './works' },
#  { vagrant_box: VAGRANT_BOX_CENTOS_7,     name: 'fuji-02', ip: '192.168.1.12', cpus: 1, memory: 512*2, sync_dir: nil },
#  { vagrant_box: VAGRANT_BOX_AMAZONLINUX,  name: 'fuji-03', ip: '192.168.1.13', cpus: 1, memory: 512*2, sync_dir: nil },
#  { vagrant_box: VAGRANT_BOX_AMAZONLINUX2, name: 'fuji-04', ip: '192.168.1.14', cpus: 1, memory: 512*2, sync_dir: nil },
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ##############################################################################
  # 共通
  ##############################################################################
  config.vm.synced_folder '.', '/vagrant', disabled: true

  ##############################################################################
  # 各VM
  ##############################################################################
  vm_specs.each do |spec|
    config.vm.define spec[:name] do |machine|
      machine.vm.box      = spec[:vagrant_box] || VAGRANT_BOX_DEFAULT
      machine.vm.hostname = spec[:name]
      machine.vm.network 'private_network', ip: spec[:ip]
      machine.vm.provider :virtualbox do |vb|
        vb.name   = "#{Pathname.pwd.basename}-#{spec[:name]}"
        vb.cpus   = spec[:cpus]
        vb.memory = spec[:memory]
      end
      if dir = spec[:sync_dir]
        machine.vm.synced_folder './' + dir, '/home/vagrant/' + dir,
          create: true, type: :rsync, owner: :vagrant, group: :vagrant,
          rsync__exclude: ['*.swp']
      end
    end
  end

  ##############################################################################
  # Ansibleをするためだけの初期化用VM
  ##############################################################################
  config.vm.define :ansible do |machine|
    machine.vm.box      = VAGRANT_BOX_UBUNTU_20
    machine.vm.hostname = 'ansible'
    machine.vm.network 'private_network', ip: '192.168.255.250'
    machine.vm.provider :virtualbox do |vb|
      vb.gui    = false
      vb.name   = "#{Pathname.pwd.basename}-ansible"
      vb.memory = 512 * 10
      vb.cpus   = 2
    end
    machine.vm.synced_folder './ansible', '/home/vagrant/ansible',
      create: true, type: :rsync, owner: :vagrant, group: :vagrant,
      rsync__exclude: ['*.swp']
    # vagrant-hosts pluginで各VM同士がhost名でアクセス可能
    machine.vm.provision 'shell', privileged: false, inline: <<-SHELL
      sudo apt update
      sudo apt install --assume-yes python3-pip make sshpass
      pip3 install --user ansible

      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo apt-key fingerprint 0EBFCD88
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt-get update
      sudo apt-get install --assume-yes docker-ce
    SHELL
  end

  ##############################################################################
  # 共通：vagrant-hosts pluginで各VM同士がhost名でアクセス可能
  ##############################################################################
  config.vm.provision :hosts, :sync_hosts => true
end
