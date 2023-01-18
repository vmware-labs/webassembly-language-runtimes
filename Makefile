# This Makefile contains the main targets for all supported language runtimes

.PHONY: php/php-*
php/php-*:
	make -C php $(subst php/php-,php-,$@)

.PHONY: php/wasmedge-php-7.4.32
php/wasmedge-php-7.4.32:
	WASMLABS_RUNTIME=wasmedge make -C php $(subst php/wasmedge-php-,php-,$@)

.PHONY: ruby/v*
ruby/v*:
	make -C ruby $(subst ruby/,,$@)

.PHONY: python/v*
python/v*:
	make -C python $(subst python/,,$@)

.PHONY: clean
clean:
	make -C php clean
