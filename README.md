## nvim-bricks
If you install **neovim** using [**nvim-install**][1] script, you will need
this plugin, to be able to use installed packages.


## Installation (using packer)
```lua
use {
  "ksk0/nvim-bricks",
  requires = "nvim-lua/plenary.nvim"
}
```


## Why and how
When **neovim** is installed using [**nvim-install**][1] script, **node**,
**ruby**, **rust**, **python**, **lua** and **perl** packages, will be
installed into user directory:
```
$HOME/.local/share/neovim/bricks
```
with following structure:
```
bricks/
├── cargo
├── lua
├── node
├── perl5
├── python
└── ruby
```
To be able to use installed packages, some environment variables
(**PATH, PYTHONPATH, ...**) have to be set. This is done with this plugin.
Variables will be updated only if corresponding directory exists.


## Usage
To be applied, script has to required once:
```lua
require("nvim-bricks")
```
**Note:** it is best to source the script, as soon as possible, if any of
the installed modules are needed afterwards.


[1]: https://github.com/ksk0/nvim-install
