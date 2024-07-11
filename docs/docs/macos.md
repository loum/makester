# Extras for macOS

## Upgrading GNU Make (macOS)
Although the macOS machines provide a working GNU `make` it is too old to support the
Makester capabilities. Instead, it is recommended to upgrade to the GNU make version
provided by Homebrew. Detailed instructions can be found at the
[Homebrew make formulae](https://formulae.brew.sh/formula/make). In short, to upgrade GNU make run:
```
brew install make
```

The `make` utility installed by Homebrew can be accessed by `gmake`.
The [Homebrew make formulae](https://formulae.brew.sh/formula/make) notes suggest how you can update your local `PATH` to use `gmake` as `make`. Alternatively, alias `make`:
```
alias make=gmake
```
