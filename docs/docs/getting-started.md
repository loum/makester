# Getting started

## Add `Makester` to your project's Git repository

- Add `Makester` as a submodule in your `git` project repository:

``` sh
git submodule add https://github.com/loum/makester.git
```

!!! note
    Some versions of `git submodule add` will only `fetch` the submodule folder without any content.
    For first time initialisation (`pull` the submodule):

``` sh
git submodule update --init --recursive
```

- Create a `Makefile` at the top-level of your `git` project repository.
Not sure what that means? Then add this snippet to your own `Makefile` to get you started:

``` sh
.SILENT:
.DEFAULT_GOAL := help

include makester/makefiles/makester.mk

help: makester-help
    @echo "(Makefile)\n"
```

!!! warning
    Make sure you have a `<tab>` character before the `@echo`.

If you already have a `Makefile`, then just include Makester:

```
include makester/makefiles/makester.mk
```

!!! info
    To ensure consistency in your project, pin to a Makester release by changing into the `makester`
    directory and checking out a [Makester release](https://github.com/loum/makester/releases).

Remember to regularly get the latest `Makester` updates:

```
git submodule update --remote --merge
```

Or, let Makester do the update for you:

``` sh
make submodule-update
```
