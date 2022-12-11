"""Template environment variables.

"""
import os
import sys
import argparse
import tempfile
import shutil
import logging
import json
import jinja2

LOG = logging.getLogger('templatester')
if not LOG.handlers:
    LOG.propagate = 0
    CONSOLE = logging.StreamHandler()
    LOG.addHandler(CONSOLE)
    FORMATTER = logging.Formatter('%(asctime)s:%(name)s:%(levelname)s: %(message)s')
    CONSOLE.setFormatter(FORMATTER)

LOG.setLevel(logging.INFO)

DESCRIPTION = """Set Interpreter values dynamically"""


def _get_environment_values(token=None) -> dict:
    """
    Returns a dictionary structure of all environment values.

    The optional *token* argument filters environment variables to only those that
    start with *token*.

    """
    if not token:
        LOG.info('Filtering disabled.  All environment variables will be mapped')
    else:
        LOG.info('Filtering environment variables starting with token "%s"', token)

    env_variables = {}
    for env_variable in os.environ:
        if not token or env_variable.startswith(token):
            env_variables[env_variable] = os.environ[env_variable]

    return env_variables


def _get_json_values(path_to_json) -> dict:
    """
    Parse JSON file *path_to_json* into a Python dictionary.

    """
    LOG.info('Sourcing JSON values from "%s"', path_to_json)

    json_mapping = {}
    if os.path.exists(path_to_json):
        with open(path_to_json) as _fp:
            json_mapping.update(json.load(_fp))
    else:
        LOG.error('Path to JSON "%s" does not exist', path_to_json)

    return json_mapping


def _build_from_template(env_map, template_file_path, write_output=False):
    """
    Take *template_file_path* and template against variables
    defined by *env_map*.

    *template_file_path* needs to end with a ``.j2`` extension as the generated
    content will be output to the *template_file_path* less the ``.j2``.

    A special custom filter ``env_override`` is available to bypass *env_map* and
    source the environment for variable substitution.  Use the custom filter
    ``env_override`` in your template as follows::

        "test" : {{ "default" | env_override('CUSTOM') }}

    Provided an environment variable as been set::

        export CUSTOM=some_value

    The template will render::

        ``some_value``

    Otherwise::

        ``default``

    """
    def env_override(value, key):
        return os.getenv(key, value)

    target_template_file_path = os.path.splitext(template_file_path)
    LOG.info('Generating templated file for "%s"', template_file_path)

    if len(target_template_file_path) > 1 and target_template_file_path[1] == '.j2':
        file_loader = jinja2.FileSystemLoader(os.path.dirname(template_file_path))
        j2_env = jinja2.Environment(autoescape=True, loader=file_loader)

        j2_env.filters['env_override'] = env_override
        template = j2_env.get_template(os.path.basename(template_file_path))

        output = template.render(**env_map)
        print(output)

        if write_output:
            out_fh = tempfile.NamedTemporaryFile()
            out_fh.write(output.encode())
            out_fh.flush()
            shutil.copy(out_fh.name, target_template_file_path[0])
            LOG.info('Templated file "%s" generated', target_template_file_path[0])
    else:
        LOG.error('Skipping "%s" templating as it does not end with ".j2"', template_file_path)


def main():
    """Script entry point.
    """
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument('template',
                        help='Path to Jinja2 template (absolute, or relative to user home)')
    parser.add_argument('-f',
                        '--filter',
                        help=('Environment variable filter '
                              '(ignored when mapping is taken from JSON file)'))
    parser.add_argument('-m',
                        '--mapping',
                        help=('Optional path to JSON mappings '
                              '(absolute, or relative to user home).'))
    parser.add_argument('-w',
                        '--write',
                        action='store_true',
                        help='Write out templated file alongside Jinja2 template')
    parser.add_argument('-q',
                        '--quiet',
                        action='store_true',
                        help='Disable logs to screen (to log level "ERROR")')

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    if args.quiet:
        logging.disable(logging.ERROR)

    if args.mapping and args.filter:
        LOG.warning(('Environment variable filter "%s" does not have effect '
                     'over JSON mapping file "%s"'), args.filter, args.mapping)

    mappings = {}
    if args.mapping:
        mappings.update(_get_json_values(args.mapping))
    else:
        mappings.update(_get_environment_values(token=(args.filter)))

    LOG.info('Template mapping values sourced:\n%s', json.dumps(mappings, indent=2))

    _build_from_template(mappings, args.template, write_output=args.write)


if __name__ == '__main__':
    main()
