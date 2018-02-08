PROXY_VERSION := 2018.02-2-g0b77ff3e3

download_binaries:
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-darwin-0.$(PROXY_VERSION).tgz
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-linux-0.$(PROXY_VERSION).tgz
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-windows-0.$(PROXY_VERSION).tgz
	tar -xzf apollo-engine-binary-darwin-0.$(PROXY_VERSION).tgz
	tar -xzf apollo-engine-binary-linux-0.$(PROXY_VERSION).tgz
	tar -xzf apollo-engine-binary-windows-0.$(PROXY_VERSION).tgz
	mv package/engineproxy_darwin_amd64 bin/
	mv package/engineproxy_linux_amd64 bin/
	mv package/engineproxy_windows_amd64.exe bin/
	rm -r package/
	rm apollo-engine-binary-darwin-0.$(PROXY_VERSION).tgz
	rm apollo-engine-binary-linux-0.$(PROXY_VERSION).tgz
	rm apollo-engine-binary-windows-0.$(PROXY_VERSION).tgz

release: download_binaries
	bundle exec rake release
