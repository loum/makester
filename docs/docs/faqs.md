# FAQs

## How do I upgrade Makester?

Use the Makester primer tool in upgrade mode:
```
resources/scripts/primer.sh -u
```

Prior to [Makester v0.2.6](https://github.com/loum/makester/releases/tag/0.2.6) you will first need
to sync the Makester `git` submodule:
``` sh
make submodule-update
```

### Why is the default `make` on macOS so old?

Apple seems to have an issue with licensing around GNU products: more specifically to the terms of the GPLv3 licence agreement. It is unlikely that Apple will provide current versions of utilities that are bound by the GPLv3 licensing constraints.
