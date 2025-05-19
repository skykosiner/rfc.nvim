# rfc.nvim
* This is a simple plugin that allows you to search for RFC's and open
them inside of neovim
## Installation
### Lazy
```lua
{
    "skykosiner/rfc.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim"
    }
}
```
## Usage
* You can run `:RFC` and just enter a search query in order to use this plugin
* You can also use `require("rfc").search_rfc()` if you wish
    * When calling this way you can also pass opts to telescope through `search_rfc()`
        * ```
            require("rfc").search_rfc({
                prompt_title = "HELLO WORLD",
                layout_stratergy = "vertical"
            })
            ```
