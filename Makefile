export MUTSUKI_IP=192.168.33.11
export KISARAGI_IP=192.168.33.12
export MUTSUKI_HOST_NAME=mutsuki
export KISARAGI_HOST_NAME=kisaragi

.PHONY: up
up:
	vagrant up

.PHONY: ssh
ssh:
	kyrat \
		-o StrictHostKeyChecking=no \
		-i .vagrant/machines/${MUTSUKI_HOST_NAME}/virtualbox/private_key \
		vagrant@${MUTSUKI_IP}

.PHONY: kisaragi
kisaragi:
	kyrat \
		-o StrictHostKeyChecking=no \
		-i .vagrant/machines/${KISARAGI_HOST_NAME}/virtualbox/private_key \
		vagrant@${KISARAGI_IP}
