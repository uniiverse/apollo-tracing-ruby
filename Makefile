PROXY_VERSION := 2018.4-20-g7a8822c14

download_binaries:
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-darwin-0.$(PROXY_VERSION).tgz
	curl -O https://registry.npmjs.org/apollo-engine-binary-linux/-/apollo-engine-binary-linux-0.$(PROXY_VERSION).tgz
	curl -O https://registry.npmjs.org/apollo-engine-binary-windows/-/apollo-engine-binary-windows-0.$(PROXY_VERSION).tgz
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
