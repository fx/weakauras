wasi:
	bundle install
	./wasi-vfs pack ruby.wasm \
		--mapdir /app::./ \
		--mapdir /usr::./3.2-wasm32-unknown-wasi-full/usr \
		-o weakauras.wasm

.PHONY: wasi