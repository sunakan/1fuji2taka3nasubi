export MUTSUKI_IP=192.168.33.11
export MUTSUKI_HOST_NAME=mutsuki

.PHONY: up
up:
	vagrant up

.PHONY: ssh
ssh:
	kyrat \
		-o StrictHostKeyChecking=no \
		-i .vagrant/machines/${MUTSUKI_HOST_NAME}/virtualbox/private_key \
		vagrant@${MUTSUKI_IP}
