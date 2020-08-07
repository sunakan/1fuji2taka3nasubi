################################################################################
# 変数
################################################################################
SYSTEM_INFORMATION := $(shell uname | tr '[:upper:]' '[:lower:]')
YTT_VERSION        := v0.28.0
YTT_DARWIN_SHA256  := be16d964964d17b463984d72ed2ec62b691b675441b38ab3ed6ea97f3fc73645
YTT_LINUX_SHA256   := 52c36853999a378f21f9cf93a443e4d0e405965c3b7d2b8e499ed5fd8d6873ab
YTT_SHA256         := $(shell bash -c 'if [ "$(SYSTEM_INFORMATION)" == "linux" ]; then echo $(YTT_LINUX_SHA256); else echo $(YTT_DARWIN_SHA256); fi')
YTT_URL            := https://github.com/k14s/ytt/releases/download/$(YTT_VERSION)/ytt-$(SYSTEM_INFORMATION)-amd64

################################################################################
# タスク
################################################################################
.PHONY: install-ytt
install-ytt:
	( command -v ./ytt ) \
	|| curl --location -o ytt $(YTT_URL)
	chmod +x ./ytt

.PHONY: check-sum-ytt
check-sum-ytt:
	echo '$(YTT_SHA256)  ytt' | shasum --algorithm 256 --check -

.PHONY: setup-ytt
setup-ytt: ## yttのインストール
	@make --no-print-directory install-ytt
	@make --no-print-directory check-sum-ytt
	./ytt --version

.PHONY: uninstall-ytt
uninstall-ytt: ## yttのアンインストール
	command -v ./ytt && rm ./ytt
