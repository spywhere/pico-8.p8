# pim

This is my attempt to bring vim into Pico-8. It leveraging Serial IO and debugging logs as a mean of reading / writing files.

**Heads up!**
- This is a very early releases of the cart, some functionalities might break under certain cases
- Line wrap is not implemented, so text insertion pass the limit would resulted in unexpected behaviour
  - As line wrap is not implemented, so is horizontal scrolling

## Reading and Writing file

pim supports reading and writing file through Serial IO and debugging logs.

### Reading Files

To read a file, simply drag and drop the file onto the Pico-8 with pim running. pim will notify through the message that file is available to read.

Once file is available to read, simply using `:e [filename]` to read a file as `[filename].p8l`.

### Writing Files

To write a file, simply using `:w [filename]` to write a file. This will always saved as `[filename].p8l` as pim is using `printh` to write the content to file.

**Heads up!** Be careful, pim will always overwrite the target file as Pico-8 does not provide an API for file systems.

## Keymap

Currently, pim supports 2 input types, devkit and a regular keypad / controller.

To switch between input types, use the Pause menu by either physically pause Pico-8 or use `:q`.

### DevKit Input

As there is a limitation on Pico-8 key interception, here are alternative keys for vim functionality.

`C-c` (Control-C) as an escape key
`Tab` (Tab) as a return key

For some of the normal mode operator, you can prefixed it with a count. For example, to move down 5 lines, you can use `5j`.

### Normal Mode

#### DevKit

- `C-c`: Clear pending operator
- `:`: Enter command line mode
- `v`/`V`/`c-v`: Enter visual / visual line / visual block mode
- `i`/`a`: Enter insert mode (at / after cursor position)
- `I`/`A`: Enter insert mode (at the start / end of a line)
- `C-e`/`C-y`: Scroll the buffer up / down by one line
- `o`: Open a new line below a current line
- `O`: Open a new line above a current line

#### Keypad

- 1st `O`: Enter command line mode
- 1st `X`: Enter insert mode at cursor position
- 2nd `O`: Enter visual mode
- 2nd `X`: Enter insert mode after cursor position

### Insert Mode

#### DevKit

- `C-c`: Exit to normal mode
- `Left`/`Down`/`Up`/`Right`: Move the cursor to the left/down/up/right

#### Keypad

- 1st `O`: Backspace
- 1st `X`: Line feed
- 2nd `O`: Exit to normal mode
- `Left`/`Right`: Move the cursor to the left/right
- `Up`/`Down`: Iterate a character at cursor position up/down

**Heads up!** Currently, there is no way to delete a line when using keypad input.

### Visual Mode

#### DevKit

- `C-c`: Clear pending operator
- `:`: Enter command line mode
- `v`/`V`/`c-v`: Enter visual / visual line / visual block mode or exit to normal mode if mode is matched
- `o`/`O`: Swap cursor and cursor's anchor point

#### Keypad

- 1st `O`: Exit to normal mode
- 2nd `X`: Enter command line mode

### Command-line Mode

#### DevKit

- `C-c`: Exit to normal mode
- `Left`/`Down`: Move the cursor to the left/down

#### Keypad

- 1st `O`: Exit to normal mode
- 1st `X`: Accept a command line
- `Left`/`Right`: Move the cursor to the left/right
- `Up`/`Down`: Iterate a character at cursor position up/down

### Motions
- `g_`: The end of the line including a new line
- `h`/`j`/`k`/`l`/`Left`/`Down`/`Up`/`Right`: Character to the left / down / up / right
- `0`/`$`: Move the cursor to the first / last character of the line
- `gg`/`G`: The top / bottom of the buffer
- `C-b`/`C-f`: The buffer up / down by a page
- `C-u`/`C-d`: The buffer up / down by half a page
- `w`/`W`: The beginning of the next word / WORD

`word`: A word consists of a sequence of letters, digits and underscores, or a sequence of other non-blank characters, separated with white space (spaces, tabs, EOL).  This can be changed with the 'iskeyword' option. An empty line is also considered to be a word.
`WORD`: A WORD consists of a sequence of non-blank characters, separated with white space. An empty line is also considered to be a WORD.

## Options

You can set the option through command line mode by using `set` command.

- `number` / `nu`: Show line number
- `relativenumber` / `rnu`: Show relative line number
- `scrolloff` / `so`: Set a scroll-off buffer limit
- `timeoutlen` / `tm`: Set a timeout duration to reset the key sequence
- `iskeyword` / `isk`: Set a set of characters to be considered as a part of `word`

You can also prefixed the option name with `no` to disable the option.

To view the current option's value, suffixed the option name with `?` to view it.

For option that accept value, you would need to pass the value (e.g. `set scrolloff=3`) in order to set the limit. Otherwise, it would just show the current limit.
