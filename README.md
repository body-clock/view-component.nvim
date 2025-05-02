# view-component.nvim

A simple Neovim plugin for some ViewComponent utilities. I was frustrated at the lack of simple tooling that would allow me to quickly switch between a ViewComponent `.rb` and `.html.erb`. This is possible to achieve using the `rails.vim` plugin with a custom `projections.json` file, but I wanted something that would work beyond a per-project configuration file.

Some other proposed functionality:
- [ ] create alternate file if it doesn't exist (with some boilerplate)

PRs and contributions welcome!

## Installation

With `lazy.nvim`:
```lua
return {
 "body-clock/view-component.nvim"
}
```

## Usage

The plugin exports a module with a `switch` function. After installation, this can be assigned to a keybind like this:
```lua
vim.keymap.set("n", "<leader>vc", function()
	require('view-component').switch()
end)
```

## Development

### Run tests

Running tests requires either

- [luarocks][luarocks]
- or [busted][busted] and [nlua][nlua]

to be installed[^1].

[^1]: The test suite assumes that `nlua` has been installed
      using luarocks into `~/.luarocks/bin/`.

You can then run:

```bash
luarocks test --local
# or
busted
```

Or if you want to run a single test file:

```bash
luarocks test spec/path_to_file.lua --local
# or
busted spec/path_to_file.lua
```

If you see an error like `module 'busted.runner' not found`:

```bash
eval $(luarocks path --no-bin)
```

For this to work you need to have Lua 5.1 set as your default version for
luarocks. If that's not the case you can pass `--lua-version 5.1` to all the
luarocks commands above.

[rockspec-format]: https://github.com/luarocks/luarocks/wiki/Rockspec-format
[luarocks]: https://luarocks.org
[luarocks-api-key]: https://luarocks.org/settings/api-keys
[gh-actions-secrets]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[busted]: https://lunarmodules.github.io/busted/
[nlua]: https://github.com/mfussenegger/nlua
[use-this-template]: https://github.com/new?template_name=nvim-lua-plugin-template&template_owner=nvim-lua
