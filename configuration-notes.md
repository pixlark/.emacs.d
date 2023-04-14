# Goals

Here are my broad goals for why I'm starting from scratch to build up a new emacs configuration:

 1. To be as productive as VSCode but with the portability and extensibility of Emacs.
   - I love VSCode and how it's instantly productive and so easy to install new packages out-of-the-box. It's basically instantaneous to get a proper dev environment for any new language or tool.
   - However, VSCode's lack of portability makes it unsuitable for working over SSH. This is frustrating as SSH is my primary way of accessing a linux box at the moment.
   - Also, VSCode is much less inherently extensible than Emacs - even things that should be basic, like setting up syntax highlighting with tree-sitter, ended up being tremendous multi-day projects that often (in the case of tree-sitter) don't even pan out. If there's an extension for something already, it's easy. If I need even a little bit of customization - it's hell.

 2. To actually understand and be able to wield the power of Emacs.
   - Historically although Emacs has been my primary text editor, I have always followed a trial-and-error approach towards getting things to work. My old configuration is a *mess* of things that I just barely got working over the course of like seven years.
   - This new configuration should be like a good software project - modular, portable, extensible, and completely understood from a base level by its creator.

# Notes on Emacs

## Variables

 - To examine a variable: `C-h v <name> RET`

## `setq` and `setq-default`

https://stackoverflow.com/a/18173666

> Variables in Emacs can be **buffer-local**, meaning that each buffer is allowed to have a separate value for that variable that overrides the global default.
> If a variable is buffer-local, then `setq` sets its value in the current buffer, and `setq-default` sets the global default value.
> If a variable is not buffer-local, then `setq` and `setq-default` do the same thing.

## `load-path`

https://www.emacswiki.org/emacs/LoadPath

The variable `load-path` contains a list of directories that get searched when loading libraries.

By default it contains:

 - Path to packages bundled with a particular emacs version.
   - windows: `C:/Program Files/Emacs/emacs-VERSION/share/emacs/VERSION/site-lisp`
   - linux: `/usr/local/share/emacs/VERSION/site-lisp`
 - Path to packages bundled with *all* installed emacs versions.
   - windows: `C:/Program Files/Emacs/emacs-VERSION/share/emacs/site-lisp`
   - linux: `/usr/local/share/emacs/site-lisp`

## Startup sequence

https://www.gnu.org/software/emacs/manual/html_node/elisp/Startup-Summary.html

Important steps:

 1. Adds subdirectories to `load-path` by recursing on each directory in `load-path`. In other words, all subdirectories of the starting directories are scanned and added to the `load-path`.
 6. Loads the **early init file** (`~/.emacs.d/early-init.el`).
 7. Calls `package-activate-all` to activate installed packages.
 9. Runs the `before-init-hook` hook.
 14. Loads the **init file** (`~/.emacs.d/init.el` or possibly `~/.emacs`/`~/.emacs.el`).
 18. Runs the `after-init-hook` hook.
 26. Runs `emacs-startup-hook`.
 29. Displays the startup screen unless `inhibit-startup-screen` or `initial-buffer-choice` are non-`nil` (or if command-line options which inihibit are specified).

## Major Modes

https://www.gnu.org/software/emacs/manual/html_node/emacs/Major-Modes.html

> Every buffer possesses a major mode, which determines the editing behaviour of Emacs while that buffer is current.
> The least specialized major mode is called *Fundamental mode*. This mode has no mode-specific redefinitions or variable settings, so that each Emacs command behaves in its most general manner, and each user option variable is in its default state.

`major-mode` is a buffer-local variable that contains a symbol indicating the name of the current major mode. "*This is set auomatically; you should not change it yourself*"

The default value of `major-mode` determines the major mode to use for files that do not specify a major mode, and for new buffers created with C-x b.

To view information on the current major mode (and minor modes), use `C-h m`.

## Keybindings

https://www.gnu.org/software/emacs/manual/html_node/emacs/Key-Bindings.html

A keymap defines bindings between a key "event" and an action. Chained keybindings (`C-x C-f` for example) use nested keymap, i.e. `C-x` maps to another keymap which defines `C-f`.

Some "prefix keymaps" for command command prefixes have variable names:

 - `ctl-x-map` for `C-x`
 - `help-map` for `C-h`
 - Most importantly, `mode-specific-map` for `C-c`. This is important, because `C-c X` where `X` is any letter are reserved for user keybinds - in other words, all the keybinds you will make.

A simple way to define a universal keybinding is through `global-set-key`:

```
(global-set-key (kbd "C-c f") 'foo)
```

where `'foo` is a symbol referring to some command.

# Notes on Emacs Lisp

## Booleans

`t` is the truth value. No quote! Just `t`.

`nil` is the false false. Again no quote. Just `nil`.

## `(interactive)`

https://www.gnu.org/software/emacs/manual/html_node/elisp/Using-Interactive.html

Placing the `(interactive)` function call at the beginning of a function turns a lisp *function* into a *command* that can be called interactively.

The arguments to `(interactive ...)` define how the arguments to the function are computed interactively.

# `use-package`

https://jwiegley.github.io/use-package/

`use-package` is a package management library. It helps make package configuration clean and universal.

Because we don't have `use-package` ourselves to install `use-package` with, we instead load it manually from `~/.emacs.d/use-package`, which is a git submodule of our `.emacs.d` git repository.

The `(use-package <package-name>)` function defines a dependency on the package `<package-name>`. To ensure that the package is installed, we use the optional argument `:ensure t`, which automatically downloads the package from the appropriate package archive if it's not available.

This `:ensure t` functionality is what allows our `.emacs.d` configuration to be so portable. After installing on a new machine by cloning the `.emacs.d` repository, everything should install and load on the first startup.

Along with `:ensure t`, we also want to explicitly mark which package archive each package comes from, just for clarity's sake (and to differentiate packages that exist in multiple archives). To do this, we use `:pin`. 

The relevant arguments to `:pin` are: `melpa`, `melpa-stable`, `gnu` (for the default GNU emacs archive), and `manual` (for manually installed packages).
