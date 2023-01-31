# This Makefile contains the main targets for all supported language runtimes

.PHONY: php/php-*
php/php-*:
	make -C php $(subst php/php-,php-,$@)

.PHONY: php/wasmedge-php-7.4.32
php/wasmedge-php-7.4.32:
	WASMLABS_RUNTIME=wasmedge make -C php $(subst php/wasmedge-php-,php-,$@)

.PHONY: php/master
php/master:
	make -C php master

.PHONY: ruby/v*
ruby/v*:
	make -C ruby $(subst ruby/,,$@)

.PHONY: python/v*
python/v*:
	make -C python $(subst python/,,$@)

.PHONY: python/wasmedge-v3.11.1
python/wasmedge-v3.11.1:
	WASMLABS_RUNTIME=wasmedge make -C python $(subst python/wasmedge-,,$@)

.PHONY: oci-python-3.11.1
oci-python-3.11.1: python/wasmedge-v3.11.1
	docker build \
		--build-arg BUILD_OUTPUT_BASE=python/build-output \
		--build-arg PYTHON_TAG=v3.11.1 \
		--build-arg PYTHON_BINARY=python-wasmedge.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.1-latest \
		-f images/python/Dockerfile \
		.



.PHONY: clean
clean:
	make -C php clean
	make -C ruby clean
	make -C python clean
	make -C libs clean

