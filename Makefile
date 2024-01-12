pack:
	bundle install
	-wget -nc -O ruby.wasm https://cdn.jsdelivr.net/npm/@ruby/3.3-wasm-wasi@2.4.1-2024-01-11-a/dist/ruby+stdlib.wasm
	mkdir -p .tmp/vfs/
	cp Gemfile .tmp/vfs/ && \
		cd .tmp/vfs/ && \
		bundle config set --local path vendor/bundle && \
		bundle config set --local without development && \
		bundle install
	bundle exec rbwasm pack ruby.wasm \
		--dir .tmp/vfs::/app \
		--output public/ruby.wasm
.PHONY: pack