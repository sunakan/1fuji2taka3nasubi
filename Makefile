export WAFU_ANSIBLE_IP=192.168.33.10
export MUTSUKI_IP=192.168.33.11
export KISARAGI_IP=192.168.33.12

.PHONY: up, plugin, chmod, ssh

up: plugin
	vagrant up

plugin:
	vagrant plugin install vagrant-hosts

chmod:
	chmod 600 .vagrant/machines/*/virtualbox/private_key

# SSHのオプションとSSH先
# $1：VMマシン名(VirtualBox側の名前)
# $2：VM側のIP(VirtualBox側の名前)
define ssh-option
	-o StrictHostKeyChecking=no \
	-o UserKnownHostsFile=/dev/null \
	-i .vagrant/machines/$1/virtualbox/private_key \
	vagrant@$2
endef
ansible: chmod
	ssh $(call ssh-option,wafu_ansible,${WAFU_ANSIBLE_IP})

mutsuki: chmod
	( which kyrat && kyrat $(call ssh-option,mutsuki,${MUTSUKI_IP}) ) \
		|| ssh $(call ssh-option,mutsuki,${MUTSUKI_IP})

kisaragi: chmod
	( which kyrat && kyrat $(call ssh-option,kisaragi,${KISARAGI_IP}) ) \
		|| ssh $(call ssh-option,kisaragi,${KISARAGI_IP})

provision:
	vagrant ssh wafu_ansible -c 'cd ansible && make provision'
