export MUTSUKI_IP=192.168.33.11
export KISARAGI_IP=192.168.33.12
export YAYOI_IP=192.168.33.13
export MUTSUKI_HOST_NAME=mutsuki
export KISARAGI_HOST_NAME=kisaragi
export YAYOI_HOST_NAME=yayoi

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

.PHONY: yayoi
yayoi:
	kyrat \
		-o StrictHostKeyChecking=no \
		-i .vagrant/machines/${YAYOI_HOST_NAME}/virtualbox/private_key \
		vagrant@${YAYOI_IP}
