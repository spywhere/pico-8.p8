# pim

This is my attempt to bring vim into Pico-8. This project is purely just a proof of concept as Pico-8 does not provide an API for reading a file.

**Heads up!**
- This is a very early releases of the cart, some functionalities might break under certain cases
- Line wrap is not implemented, so text insertion pass the limit would resulted in unexpected behaviour
  - As line wrap is not implemented, so is horizontal scrolling

## Keymap

As there is a limitation on Pico-8 key interception, here are alternative keys for vim functionality.

`C-c` (Control-C) as an escape key
`Tab` (Tab) as a return key

For some of the normal mode operator, you can prefixed it with a count. For example, to move down 5 lines, you can use `5j`.

### Normal Mode
- `C-c`: Clear pending operator
- `:`: Enter command line mode
- `v`/`V`/`c-v`: Enter visual / visual line / visual block mode
- `i`/`a`: Enter insert mode (at / after a cursor position)
- `I`/`A`: Enter insert mode (at the start / end of a line)
- `C-e`/`C-y`: Scroll the buffer up / down by one line
- `o`: Open a new line below a current line
- `O`: Open a new line above a current line

### Insert Mode
- `C-c`: Exit to normal mode
- `Left`/`Down`/`Up`/`Right`: Move the cursor to the left/down/up/right

### Visual Mode
- `C-c`: Clear pending operator
- `:`: Enter command line mode
- `v`/`V`/`c-v`: Enter visual / visual line / visual block mode or exit to normal mode if mode is matched
- `o`/`O`: Swap cursor and cursor's anchor point

### Motions
- `g_`: The end of the line including a new line
- `h`/`j`/`k`/`l`/`Left`/`Down`/`Up`/`Right`: Character to the left / down / up / right
- `0`/`$`: Move the cursor to the first / last character of the line
- `gg`/`G`: The top / bottom of the buffer
- `C-b`/`C-f`: The buffer up / down by a page
- `C-u`/`C-d`: The buffer up / down by half a page

## Options

You can set the option through command line mode by using `set` command.

- `number` / `nu`: Show line number
- `relativenumber` / `rnu`: Show relative line number
- `scrolloff` / `so`: Set a scroll-off buffer limit
- `timeoutlen` / `tm`: Set a timeout duration to reset the key sequence

You can also prefixed the option name with `no` to disable the option.

To view the current option's value, suffixed the option name with `?` to view it.

For option that accept value, you would need to pass the value (e.g. `set scrolloff=3`) in order to set the limit. Otherwise, it would just show the current limit.
