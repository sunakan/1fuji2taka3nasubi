.PHONY: setup-ytt
setup-ytt:
	make --file ./Makefile.ytt setup-ytt
################################################################################
# 変数チェック(主にdebug用途)
################################################################################
define vm-specs-json
	cat ./vm-specs.yml | ./ytt -f- --output json
endef
.PHONY: check
check:
	echo $(ANSIBLE_IP)
	echo $(FUJI_01_IP)
	$(call vm-specs-json) | jq --raw-output '.vm_specs[].vagrant_box' | xargs -I {vagrant-box} echo {vagrant-box}
	echo $(SSH_COMMAND)

ANSIBLE_HOST := ansible
ANSIBLE_IP   := $(shell $(call vm-specs-json) | jq --raw-output '.ansible.ip')
FUJI_01_HOST := fuji-01
FUJI_02_HOST := fuji-02
FUJI_03_HOST := fuji-03
FUJI_04_HOST := fuji-04
FUJI_01_IP   := $(shell $(call vm-specs-json) | jq --raw-output '.vm_specs[] | select(.name == "$(FUJI_01_HOST)") | .ip')
FUJI_02_IP   := $(shell $(call vm-specs-json) | jq --raw-output '.vm_specs[] | select(.name == "$(FUJI_02_HOST)") | .ip')
FUJI_03_IP   := $(shell $(call vm-specs-json) | jq --raw-output '.vm_specs[] | select(.name == "$(FUJI_03_HOST)") | .ip')
FUJI_04_IP   := $(shell $(call vm-specs-json) | jq --raw-output '.vm_specs[] | select(.name == "$(FUJI_04_HOST)") | .ip')

################################################################################
# sshコマンドを変数として扱う
# sshのラッパーがあれば、それを優先して使いたい
################################################################################
SSH_COMMAND := $(shell (command -v kyrat) || (command -v sshrc) || (command -v ssh))

################################################################################
# VagrantでたてたVM同士が名前解決できるようにするプラグイン
################################################################################
.PHONY: install-plugin
install-plugin:
	vagrant plugin install vagrant-hosts
################################################################################
# Vagrant boxをpull
################################################################################
.PHONY: pull-boxes
pull-boxes:
	$(call vm-specs-json) \
	| jq --raw-output '.vm_specs[].vagrant_box' \
	| xargs -I {vagrant-box} vagrant box add {vagrant-box}

.PHONY: up
up: plugin
	vagrant up

################################################################################
# VagrantでたてたVMの秘密鍵をtmp/以下の適当なディレクトリに持っていく
# Windowsだとsshの秘密鍵の権限がWSLで600にできないため
# Macなら不要だけど、依存しているので動かす
################################################################################
TMP_DIR_PREFIX := vagrant-ssh-keys
.PHONY: clean-vagrant-keys
clean-vagrant-keys:
	rm -rf /tmp/$(TMP_DIR_PREFIX)*
.PHONY: vagrant-keys
vagrant-keys: clean-vagrant-keys
	$(eval TMP_DIR := $(shell mktemp -d -t $(TMP_DIR_PREFIX)-XXXXX))
	ls .vagrant/machines/*/virtualbox/private_key | xargs -I {key} rsync --relative {key} $(TMP_DIR)/
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
	$(SSH_COMMAND) $(call ssh-option,$(1)) vagrant@$(2)
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
# Fuji VM
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
