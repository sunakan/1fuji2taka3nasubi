include makefiles/ytt.mk
include makefiles/help.mk

################################################################################
# 変数
################################################################################
TMP_DIR_PREFIX := vagrant-ssh-keys
SSH_COMMAND    := $(shell (command -v kyrat) || (command -v sshrc) || (command -v ssh))
VM_KEY     := fuji-01
VM_IP      := $(shell cat vm-ip.yml | ./ytt -f- --output json | jq --compact-output --raw-output '.["$(VM_KEY)"]["ip"]')
ANSIBLE_IP := $(shell cat vm-ip.yml | ./ytt -f- --output json | jq --compact-output --raw-output '.["ansible"]["ip"]')

################################################################################
# マクロ
################################################################################
# $(1)：秘密鍵の場所
# $(2)：VMマシン名(VirtualBox側の名前)
define ssh-option
-o StrictHostKeyChecking=no \
-o UserKnownHostsFile=/dev/null \
-i $(1)/.vagrant/machines/$(2)/virtualbox/private_key
endef

################################################################################
# タスク
################################################################################
.PHONY: install-plugin
install-plugin: ## VagrantでたてたVM同士が名前解決するプラグインを入れる
	vagrant plugin install vagrant-hosts

.PHONY: pull-boxes
pull-boxes: ## vagrant box add 色々
	vagrant box add bento/ubuntu-20.04
	vagrant box add bento/ubuntu-18.04
	vagrant box add bento/centos-7
	vagrant box add jonnangle/amazonlinux
	vagrant box add bento/amazonlinux-2

# Windowsだとsshの秘密鍵の権限がWSLで400にできないため
# Macなら不要だけど、依存しているので動かす
.PHONY: setup-vagrant-keys
setup-vagrant-keys: ## VMの秘密鍵をtmp/以下に持っていき、400にする
	rm -rf /tmp/$(TMP_DIR_PREFIX)*
	$(eval TMP_DIR := $(shell mktemp -d -t $(TMP_DIR_PREFIX)-XXXXX))
	mkdir -p $(TMP_DIR)
	ls .vagrant/machines/*/virtualbox/private_key | xargs -I {key} rsync --relative {key} $(TMP_DIR)/
	chmod 400 $(TMP_DIR)/.vagrant/machines/*/virtualbox/private_key

.PHONY: rsync-vm-ssh-keys-to-ansible-vm
rsync-vm-ssh-keys-to-ansible-vm: setup-vagrant-keys
	rsync \
		--archive \
		--recursive \
		--update \
		--compress \
		--rsh 'ssh $(call ssh-option,$(TMP_DIR),ansible)' \
		$(TMP_DIR)/ vagrant@$(ANSIBLE_IP):/tmp/private-ssh-keys/

.PHONY: ssh-ansible
ssh-ansible: setup-vagrant-keys ## ansible用のvmにssh(デバッグ用)
	$(SSH_COMMAND) $(call ssh-option,$(TMP_DIR),ansible) vagrant@$(ANSIBLE_IP)

.PHONY: provision-debug
provision-debug: setup-vagrant-keys
	ssh $(call ssh-option,$(TMP_DIR),ansible) vagrant@$(ANSIBLE_IP) 'cd ansible && make provision-hello'

.PHONY: provision-development
provision-development: setup-vagrant-keys
	ssh $(call ssh-option,$(TMP_DIR),ansible) vagrant@$(ANSIBLE_IP) 'cd ansible && make provision-development'


.PHONY: ssh
ssh: setup-vagrant-keys ## VM_KEYに対応したvmへssh($ make ssh VM_KEY=fuji-01)
	$(SSH_COMMAND) $(call ssh-option,$(TMP_DIR),$(VM_KEY)) vagrant@$(VM_IP)
