"""Template environment variables.

"""
from typing import Text
import json
import os
import shutil
import tempfile

from logga import log
import jinja2


def get_environment_values(token: Text = None) -> dict:
    """
    Returns a dictionary structure of all environment values.

    The optional *token* argument filters environment variables to only those that
    start with *token*.

    """
    if not token:
        log.info("Filtering disabled. All environment variables will be mapped")
    else:
        log.info('Filtering environment variables starting with token "%s"', token)

    env_variables = {}
    for env_variable in os.environ:
        if not token or env_variable.startswith(token):
            env_variables[env_variable] = os.environ[env_variable]

    return env_variables


def get_json_values(path_to_json) -> dict:
    """
    Parse JSON file *path_to_json* into a Python dictionary.

    """
    log.info('Sourcing JSON values from "%s"', path_to_json)

    json_mapping = {}
    if os.path.exists(path_to_json):
        with open(path_to_json, encoding="utf-8") as _fp:
            json_mapping.update(json.load(_fp))
    else:
        log.error('Path to JSON "%s" does not exist', path_to_json)

    return json_mapping


def build_from_template(env_map, template_file_path, write_output=False):
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
    log.info('Generating templated file for "%s"', template_file_path)

    if len(target_template_file_path) > 1 and target_template_file_path[1] == ".j2":
        file_loader = jinja2.FileSystemLoader(os.path.dirname(template_file_path))
        j2_env = jinja2.Environment(autoescape=True, loader=file_loader)

        j2_env.filters["env_override"] = env_override
        template = j2_env.get_template(os.path.basename(template_file_path))

        output = template.render(**env_map)
        print(output)

        if write_output:
            with tempfile.NamedTemporaryFile() as out_fh:
                out_fh.write(output.encode())
                out_fh.flush()
                shutil.copy(out_fh.name, target_template_file_path[0])
                log.info('Templated file "%s" generated', target_template_file_path[0])
    else:
        log.error(
            'Skipping "%s" templating as it does not end with ".j2"', template_file_path
        )
