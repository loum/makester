# Makester

Makester is aimed to be a centralised, reusable tool kit for tasks that you use regularly in
your projects. Makester was inspired by [Modern Make](https://makefile.site/){target="\_blank"}
and created in response to a proliferation of disjointed Makefiles. These accumulated over
the years and eventually became hard to maintain. Now, projects can follow a consistent
infrastructure management pattern that is version controlled and easy to use. Pin to a
particular Makester release and ensure consistency across your projects.

Makester can fill the void as an Integrated Developer Platform that provides a consistent tooling
framework that is used throughout all of your coding projects and does not lock you into cloud
provider's managed services. Avoid re-inventing the wheel and just focus on your problem domain.

If you use Python, Docker or Kubernetes daily then Makester can help you.

## Why Use Makester?

- No need to install anything, unless you want to use the optional Makester subsystems, such as
  [MicroK8s](https://microk8s.io/){target="\_blank"} or
  [Minikube](https://kubernetes.io/docs/tutorials/hello-minikube/){target="\_blank"}. You will need to install those
  binaries yourself.
- Lightweight. It's just GNU `make`.
- Simplifies your CI/CD pipelines. Long, unwieldy commands can be abstracted by a `make` command.
  For example, `make image-build`.
- Simplify repetitive tasks with short, easy to remember `make` commands. For example, `make tests`, which I further alias to `mt` as I run it a million times a day ...
- Makester does not intend to tell you **_how_** you should do things. It's just there to help you
  work common and repetitive tasks. If something you need is missing, then feel free to create a `Makefile` and
  share.

## Where do I start?

Check out the [Getting started](getting-started.md) page.

______________________________________________________________________

[top](#makester)
