export ENVIRONMENT=vagrant

version:
	ansible-playbook --version

dry-provision:
	ansible-playbook \
		--inventory ./inventories/${ENVIRONMENT}/hosts \
		--check \
		./main.yml
#		--ask-pass \

provision:
	ansible-playbook \
		--inventory ./inventories/${ENVIRONMENT}/hosts \
		./main.yml
