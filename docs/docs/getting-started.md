# Getting started

## Add `Makester` to your Project's Git Repository

- Add `Makester` as a submodule in your `git` project repository:

```
git submodule add https://github.com/loum/makester.git
```

!!! note
    Some versions of `git submodule add` will only `fetch` the submodule folder without any content.
    For first time initialisation (`pull` the submodule):

```
git submodule update --init --recursive
```

- Create a `Makefile` at the top-level of your `git` project repository.
Not sure what that means? Then just copy over the
[sample Makefile](https://github.com/loum/makester/blob/main/sample/Makefile>) and tweak the targets to suit.

- Include the required Makester target into your `Makefile`. For example:

```
include makester/makefiles/makester.mk
```

- The preferred arrangement is to pin to a Makester release by Changing into the `makester`
directory and checking out a [Makester release](https://github.com/loum/makester/releases)

- Remember to regularly get the latest `Makester` code base:

```
git submodule update --remote --merge
```

   Or, let Makester do the update for you:

```
make submodule-update
```

## Extras for macOS

### Upgrading GNU Make
Although macOS provides a working GNU `make`, it is too old to support the capabilities within [makester](https://github.com/loum/makester). Instead, it is recommended to upgrade to the GNU make version provided by [Homebrew](https://brew.sh/):. Detailed instructions can be found at https://formulae.brew.sh/formula/make. In short, to upgrade GNU make run:
```
brew install make
```
The `make` utility installed by Homebrew can be accessed by `gmake`. The [Homebrew `make` formula](https://formulae.brew.sh/formula/make) detail how you can update your local `PATH` to use `gmake` as `make`. Alternatively, alias `make`:
```
alias make=gmake
```
