ANSIBLE_IP := 192.168.255.250
FUJI_01_IP := 192.168.33.11
FUJI_02_IP := 192.168.33.12
FUJI_03_IP := 192.168.33.13
FUJI_04_IP := 192.168.33.14

################################################################################
# Vagrantで建てたVM同士が名前解決できるようにするプラグイン
################################################################################
.PHONY: install-plugin
install-plugin:
	vagrant plugin install vagrant-hosts
.PHONY: up
up: plugin
	vagrant up

################################################################################
# Windowsだとsshのprivate_keyの権限がWSLで600にできないので、/tmp/に持っていく
# Macなら不要
################################################################################
TMP_DIR_PREFIX := vagrant-ssh-keys
.PHONY: clean-vagrant-keys
clean-vagrant-keys:
	rm -rf /tmp/$(TMP_DIR_PREFIX)*
.PHONY: vagrant-keys
vagrant-keys: clean-vagrant-keys
	$(eval TMP_DIR := $(shell mktemp --directory -t $(TMP_DIR_PREFIX)-XXXXX))
	ls .vagrant/machines/*/virtualbox/private_key | xargs -I {key} cp --parents {key} $(TMP_DIR)/
.PHONY: chmod-vagrant-keys
chmod-vagrant-keys: vagrant-keys
	chmod 600 $(TMP_DIR)/.vagrant/machines/*/virtualbox/private_key

################################################################################
# SSHのオプションとSSH先
################################################################################
# $(1)：VMマシン名(VirtualBox側の名前)
define ssh-option
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -i $(TMP_DIR)/.vagrant/machines/$(1)/virtualbox/private_key
endef

################################################################################
# SSHコマンド
################################################################################
# $(1)：VMマシン名(VirtualBox側の名前)
# $(2)：VM側のIP(VirtualBox側の名前)
define ssh
	( kyrat $(call ssh-option,$(1)) vagrant@$(2) ) \
		|| ( sshrc $(call ssh-option,$(1)) vagrant@$(2) ) \
		|| ssh $(call ssh-option,$(1)) vagrant@$(2)
endef

################################################################################
# Ansible
################################################################################
.PHONY: rsync-ssh-keys
rsync-ssh-keys: chmod-vagrant-keys
	rsync --archive --recursive --update --compress --rsh 'ssh $(call ssh-option,ansible,$(ANSIBLE_IP))' \
		$(TMP_DIR)/ vagrant@$(ANSIBLE_IP):/tmp/private-ssh-keys/
.PHONY: ssh-ansible
ssh-ansible: chmod-vagrant-keys rsync-ssh-keys
	$(call ssh,ansible,$(ANSIBLE_IP))
.PHONY: provision-hello
provision-hello: chmod-vagrant-keys rsync-ssh-keys
	ssh $(call ssh-option,ansible,$(ANSIBLE_IP)) vagrant@$(ANSIBLE_IP) \
		'cd ansible && make provision-hello'
.PHONY: provision-development
provision-development: chmod-vagrant-keys rsync-ssh-keys
	ssh $(call ssh-option,ansible,$(ANSIBLE_IP)) vagrant@$(ANSIBLE_IP) \
		'cd ansible && make provision-development'

################################################################################
# Fuji
################################################################################
.PHONY: ssh-fuji-01
ssh-fuji-01: chmod-vagrant-keys
	$(call ssh,fuji-01,$(FUJI_01_IP))
.PHONY: ssh-fuji-02
ssh-fuji-02: chmod-vagrant-keys
	$(call ssh,fuji-02,$(FUJI_02_IP))
.PHONY: ssh-fuji-03
ssh-fuji-03: chmod-vagrant-keys
	$(call ssh,fuji-03,$(FUJI_03_IP))
.PHONY: ssh-fuji-04
ssh-fuji-04: chmod-vagrant-keys
	$(call ssh,fuji-04,$(FUJI_04_IP))
