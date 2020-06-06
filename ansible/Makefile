ENVIRONMENT_DEVELOPMENT := vagrant-development
ENVIRONMENT_STAGING:= vagrant-staging

################################################################################
# Ansible デバッグ用
################################################################################
.PHONY: provision-hello
provision-hello:
	~/.local/bin/ansible-playbook \
		--inventory ./inventories/$(ENVIRONMENT_DEVELOPMENT)/hosts \
		./hello.yml

.PHONY: provision-development
provision-development:
	~/.local/bin/ansible-playbook \
		--inventory ./inventories/$(ENVIRONMENT_DEVELOPMENT)/hosts \
		./main.yml
