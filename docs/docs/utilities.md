# Utilities

The Makester utilities are Python scripts that available to your project when you create
the Makester environment with:
```
make py-install-makester
```

The target script is `venv/bin/makester`:
```
usage: makester [-h] [-q] {primer,templater,backoff} ...

Makester CLI tool

positional arguments:
  {primer,templater,backoff}
    primer              Makester Python project primer
    templater           Makester document templater
    backoff             Makester backoff until all ports ready

options:
  -h, --help            show this help message and exit
  -q, --quiet           Disable logs to screen (to log level "ERROR")
```

## `makester backoff`

!!! note "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    `src/waitster.py` was refactored into the `makester backoff` CLI in
    [Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4).

Wait until dependent service is ready:
```
venv/bin/makester backoff --help
```
```
positional arguments:
  host                  Connection host
  port                  Backoff port number until ready

options:
  -h, --help            show this help message and exit
  -d DETAIL, --detail DETAIL
                        Meaningful description for backoff port
```
`makester backoff` will poll `port` for 300 seconds before a time out error is reported.

### `makester backoff` Example
Start listening on a port:
```
nc -l 19999
```

Poll the port:
```
venv/bin/makester backoff  localhost 19999 --detail "Just a port check ..."
```

```
2022-12-13 07:55:20,037:makester:INFO: Checking host:port localhost:19999 Just a port check ... ...
2022-12-13 07:55:21,042:makester:INFO: Port 19999 ready
```

## `makester templater`
!!! note "[Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4)"
    `src/templatester.py` was refactored into the `makester templater` CLI in
    [Makester v0.1.4](https://github.com/loum/makester/releases/tag/0.1.4).

Template against environment variables or optional JSON values (`--mapping` switch):
```
venv/bin/makester templater --help
```

```
usage: makester templater [-h] [-f FILTER] [-m MAPPING] [-w] template

positional arguments:
  template              Path to Jinja2 template (absolute, or relative to user home)

options:
  -h, --help            show this help message and exit
  -f FILTER, --filter FILTER
                        Environment variable filter (ignored when mapping is taken from JSON file)
  -m MAPPING, --mapping MAPPING
                        Optional path to JSON mappings (absolute, or relative to user home)
  -w, --write           Write out templated file alongside Jinja2 template
```

`makester templater` takes a file path as defined by the `template` positional argument and
renders the template against target variables. The variables can be specified as a JSON
document defined by `--mapping`.

The `template` files needs to end with a `.j2` extension. If the `--write` switch is provided,
then the generated content will be output to the `template` path less the `.j2` extension.

A special custom filter `env_override` is available to bypass `MAPPING` values and source
the environment for variable substitution. Use the custom filter `env_override` in your template as follows:
```
"test" : {{ "default" | env_override('CUSTOM') }}
```

Provided an environment variable as been set:
```
export CUSTOM=some_value
```

The template will render:
```
test: some_value
```

Otherwise:
```
test: default
```

### `makester templater` Example
Create the Jinja2 template:
```
cat << EOF > my_template.j2
This is my CUSTOM variable value: {{ CUSTOM }}
EOF
```

Template!
```
CUSTOM=bananas venv/bin/makester --quiet templater my_template.j2
```

Output:
```
This is my CUSTOM variable value: bananas
```