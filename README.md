# view-component.nvim

A simple Neovim plugin for ViewComponent utilities. Quickly switch between a
ViewComponent `.rb` and `.html.erb` file without per-project configuration.

PRs and contributions welcome!

## Installation

With `lazy.nvim`:

```lua
return {
  "body-clock/view-component.nvim"
}
```

## Usage

The plugin exports a module with a `switch` function. Assign it to a keybind:

```lua
vim.keymap.set("n", "<leader>vc", function()
  require('view-component').switch()
end)
```

### Switching between files

Calling `switch` from a `.rb` or `.html.erb` file under `app/components/`
opens the alternate file. If the current file is not under `app/components/`,
a warning is shown and no action is taken.

### Creating missing files

If the alternate file does not exist, you will be prompted to create it.
Confirming creates any necessary directories and opens the new file. For `.rb`
files, boilerplate is generated automatically based on the file path:

```text
app/components/ui/button_component.rb
```

produces:

```ruby
module Ui
  class ButtonComponent < ViewComponent::Base
    def initialize
    end
  end
end
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

[luarocks]: https://luarocks.org
[busted]: https://lunarmodules.github.io/busted/
[nlua]: https://github.com/mfussenegger/nlua
