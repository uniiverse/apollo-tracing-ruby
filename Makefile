download_binaries:
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-darwin-0.2017.10-408-g497e1410.tgz
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-linux-0.2017.10-408-g497e1410.tgz
	curl -O https://registry.npmjs.org/apollo-engine-binary-darwin/-/apollo-engine-binary-windows-0.2017.10-408-g497e1410.tgz
	tar -xzf apollo-engine-binary-darwin-0.2017.10-408-g497e1410.tgz
	tar -xzf apollo-engine-binary-linux-0.2017.10-408-g497e1410.tgz
	tar -xzf apollo-engine-binary-windows-0.2017.10-408-g497e1410.tgz
	mv package/engineproxy_darwin_amd64 bin/
	mv package/engineproxy_linux_amd64 bin/
	mv package/engineproxy_windows_amd64.exe bin/
	rm -r package/
	rm apollo-engine-binary-darwin-0.2017.10-408-g497e1410.tgz
	rm apollo-engine-binary-linux-0.2017.10-408-g497e1410.tgz
	rm apollo-engine-binary-windows-0.2017.10-408-g497e1410.tgz

release: download_binaries
	bundle exec rake release
