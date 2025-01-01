# Utilities

## Getting started

The Makester utilities provide reuseable tooling across all of your projects.

!!! note
    Makester follows the [Cross-Desktop Group](https://specifications.freedesktop.org/basedir-spec/latest/#variables){target="\_blank"}
    specification by installing the `makester` utility into `$HOME/.local/bin`.

## `makester` usage

```sh title="makester usage message."
└> makester
Usage: makester [OPTIONS] COMMAND [ARGS]...

 Makester CLI tool

╭─ Options ────────────────────────────────────────────────────────────────────────────────────────╮
│ --quiet          Disable logs to screen (to log level "ERROR")                                   │
│ --help           Show this message and exit.                                                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Commands ───────────────────────────────────────────────────────────────────────────────────────╮
│ backoff       Wait until dependent service is ready.                                             │
│ templater     Template against environment variables or optional JSON values.                    │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

## `makester backoff`

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    `src/waitster.py` was refactored into the `makester backoff` CLI in [Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4).

Wait until dependent service is ready:

```sh
makester backoff --help
```

```sh title="makester backoff usage message."
 Usage: makester backoff [OPTIONS] HOST PORT

 Wait until dependent service is ready.

╭─ Arguments ──────────────────────────────────────────────────────────────────────────────────────╮
│ *    host      TEXT     Host name of service connection. [required]                              │
│ *    port      INTEGER  Service port number. [required]                                          │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Options ────────────────────────────────────────────────────────────────────────────────────────╮
│ --detail  -d      TEXT  Meaningful description for backoff port [default: Service]               │
│ --help                  Show this message and exit.                                              │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

`makester backoff` will poll `port` for 300 seconds before a time out error is reported.

### `makester backoff` Example

Start listening on a port:

```sh
nc -l 19999
```

Poll the port:

```sh
makester backoff localhost 19999 --detail "- Just a port check"
```

```sh title="Backoff polling port 19999 for service readiness."
Checking host:port localhost:19999 - Just a port check ...
Server is accepting connection requests 🚀
```

## `makester templater`

!!! tag "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    `src/templatester.py` was refactored into the `makester templater` CLI in [Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4).

Template against environment variables or optional JSON values (`--mapping` switch):

```sh
makester templater --help
```

```sh title="makester templater usage message."
╭─ Arguments ──────────────────────────────────────────────────────────────────────────────────────╮
│ *    template      TEXT  Path to Jinja2 template (absolute, or relative to user home) [required] │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Options ────────────────────────────────────────────────────────────────────────────────────────╮
│ --filter   -f      TEXT  Environment variable filter (ignored when mapping is taken from JSON    │
│                          file)                                                                   │
│ --mapping  -m      TEXT  path to JSON mappings (absolute, or relative to user home)              │
│ --write    -w            Write out templated file alongside Jinja2 template                      │
│ --help                   Show this message and exit.                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

`makester templater` takes a file path as defined by the `template` positional argument and
renders the template against target variables. The variables can be specified as a JSON
document defined by `--mapping`.

The `template` files needs to end with a `.j2` extension. If the `--write` switch is provided,
then the generated content will be output to the `template` path less the `.j2` extension.

A special custom filter `env_override` is available to bypass `MAPPING` values and source
the environment for variable substitution. Use the custom filter `env_override` in your template as follows:

```sh
"test" : {{ "default" | env_override('CUSTOM') }}
```

Provided an environment variable as been set:

```sh
export CUSTOM=some_value
```

The template will render:

```sh
test: some_value
```

Otherwise:

```sh
test: default
```

### `makester templater` Example

Create the Jinja2 template:

```sh
cat << EOF > my_template.j2
This is my CUSTOM variable value: {{ CUSTOM }}
EOF
```

Template!

```sh
CUSTOM=bananas makester --quiet templater my_template.j2
```

```sh title="makester templater example output."
This is my CUSTOM variable value: bananas
```

______________________________________________________________________

[top](#utilities)
