# Documentation
Makester's documentation subsystem helps you prepare and maintain your site's project documentation.

Sadly, technical documentation has become an oversight in many projects. Makester's documentation subsystem attempts to reduce the burden of project documentation setup and maintenance that is not bound to a single programming language. It's just Markdown.

Makester documentation leverages [the Materials for MkDocs theme](https://squidfunk.github.io/mkdocs-material/).

The Makester documentation subsystem help lists the available commands:
```
make help-docs
```

## Command Reference

### Site Documentation Scaffolding
Create the site documentation directory structure
[based on Material for MkDocs: Creating your site](https://squidfunk.github.io/mkdocs-material/creating-your-site/).
```
make docs-project-create
```

If the default settings are accepted, this will create a `docs` directory under the top level of you project code repository. The minimal content is:
```
docs
├── docs
│   └── index.md
└── mkdocs.yml
```
Additions will need to be performed manually by adding new content under the `docs` directory. Some things you probably want to do in the first instance include:

- Change the name of your site's documentation
  - Edit the `site_name` setting in the `docs/mkdocs.yml`.
- Change the theme:
  - Unless you are happy the the standard [MkDocs default theme](https://www.mkdocs.org/), enable the MkDocs `material` theme. Append the following to `docs/mkdocs.yml`:
```
theme:
  name: material
```

### Preview While You Write
Enable the [MkDocs preview server](https://squidfunk.github.io/mkdocs-material/creating-your-site/#previewing-as-you-write).

```
make docs-preview
```

### Site Documentation Builder
Build your site's [static documentation](https://squidfunk.github.io/mkdocs-material/creating-your-site/#building-your-site).
```
make docs-build
```

## Variables

### `MAKESTER__DOCS_DIR`
Location of MkDocs documentation structure (default `<MAKESTER__PROJECT_DIR>/docs`).

### `MAKESTER__DOCS_IP`
The documentation preview server's IP address (default `<MAKESTER__LOCAL_IP>`).

### `MAKESTER__DOCS_PORT`
The documentation preview server's port (default `8000`).

### `MAKESTER__DOCS_BUILD_PATH`
The directory to output the result of the documentation build (default `<MAKESTER__DOCS_DIR>/out`).

---
[top](#documentation)
