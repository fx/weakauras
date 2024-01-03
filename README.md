# WeakAuras Ruby DSL

Being old and not wanting all the clutter, I play all WoW classes using a "whack-a-mole" style weakaura that only shows buttons I actually can/should be pressing, as opposed to all buttons, with some emphasis or cooldown, as is typical for most player's UI.

I didn't feel like copying/editing/changing these in the in-game UI anymore, so I created this proof of concept Ruby DSL approach to generating them.

### Examples

Show `Shadow Word: Pain` on a Shadow Priest if the debuff is missing from the target.

```
title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
end
```

### Install

```
sudo apt-get install ruby ruby-dev liblua5.1-0 libffi luarocks
luarocks install --local libdeflate rxi-json

# LibSerialize has no rockspec :(
wget https://raw.githubusercontent.com/rossnichols/LibSerialize/master/LibSerialize.lua
```

### Run

See `make.rb`

### The WASI Way

Grab [ruby.wasm](https://github.com/ruby/ruby.wasm), run `make`

Run via `wasmtime`:

```
wasmtime weakauras.wasm \
	--env BUNDLE_GEMFILE=/app/Gemfile \
	--env BUNDLE_FROZEN=1 \
	-- /app/src/make.rb --json
```

Only JSON for now, LUA for export packaging coming up next.

### To Do

- [x] [Make WASI](https://github.com/ruby/ruby.wasm)
- [ ] [Add LUA WASM](https://www.fermyon.com/wasm-languages/lua) for import/export (JSON decode/encode) support, instead of executing via ruby
- [ ] Host browser executable on the interwebs
