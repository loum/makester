# MicroK8s

!!! tag "[Makester v0.2.4](https://github.com/loum/makester/releases/tag/0.2.4)"

[MicroK8s](https://microk8s.io/){target="\_blank"} is a lightweight Kubernetes implementation
that is ideal for localised testing, experimentation and for shaking out production deployments.

!!! note
    This Makester addon is not intended to be a replacement for full suite of
    [MicroK8s commands](https://microk8s.io/docs/command-reference){target="\_blank"}. Rather, it
    is abstracting the most basic set of instructions required to get a minimal Kubernetes
    instance operational with minimal fuss.

    See the [MicroK8s commands reference](https://microk8s.io/docs/command-reference){target="\_blank"} for the full
    suite of available commands. Similarly,
    [`microk8s kubectl`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands){target="\_blank"}
    provides the list of commands to run against the Kubernetes cluster.

## Getting started

If managing `Makefile` includes manually, you must append `microk8s` to `MAKESTER__INCLUDES` to enable
the Makester MicroK8s subsystem.

Start by checking the MicroK8s status:

```sh title="MicroK8s status: pristine environment."
make microk8s-status
```

If the `microk8s` executable is not found, then a link to the installation notes is displayed as
follows:

```sh title="MicroK8s not installed."
### Checking MicroK8s status ...
### MAKESTER__MICROK8S: <undefined>
### MAKESTER__MICROK8S_EXE_NAME set as "microk8ss"
### "microk8s" not found
### Install notes: https://microk8s.io/docs/getting-started
makefiles/microk8s.mk:16: *** ###.  Stop.
```

Install [Microk8s](https://microk8s.io/docs/getting-started){target="\_blank"} suited to your platform.

MacOS users will need to also install [Multipass](https://multipass.run/){target="\_blank"}:

```sh title="Install Multipass."
### Checking MicroK8s status ...
You need 'multipass' set-up to build snaps: https://multipass.run.
gmake: *** [makefiles/microk8s.mk:19: _uk8s-cmd] Error 2
```

To start the essential Kubernetes services with minimal fuss:

```sh title="Quick start convenience target."
make microk8s-up
```

!!! note
    For [multipass](https://multipass.run/) deployments, it is possible to configure the underlying VM resources that are passed to the `microk8s install` command via the available `MUTLIPASS_*` settings. The default arrangement is as follows:

    ```bash
    make microk8s-up MULTIPASS_CPU=2 MULTIPASS_MEMORY=4 MULTIPASS_DISK=50 MULTIPASS_CHANNEL="1.28/stable" MULTIPASS_IMAGE=22.04
    ```

`make microk8s-up` should cater for the majority of scenarios. However, Makester also provides more
granular targets that allow you to customise and explore the Kubernetes cluster.

To clean up all resources:

```sh title="Clean up all resources."
make microk8s-down
```

## Command reference

### All-in-one Kubernetes service starter

A convenience target to start the most essential Kubernetes services, such as DNS, and
provide access to the Kubernetes dashboard:

```sh
make microk8s-up
```

### All-in-one Kubernetes service stopper

Restore the MicroK8s to original state and release all resources:

```sh
make microk8s-down
```

!!! note
    For Multipass environments, this target will also stop the underlying `microk8s-vm`.

### Start MicroK8s

Start a local, lightweight Kubernetes:

```sh
make microk8s-start
```

### Wait for MicroK8s services to initialise

In addition to the `microk8s status` target, this alternate status target will wait until all of
the Kubernetes targets are ready:

```sh
make microk8s-wait
```

### MicroK8s version

Print the installed MicroK8s version and revision number:

```sh
make microk8s-version
```

```sh title="MicroK8s version sample output."
Client Version: v1.26.3
Kustomize Version: v4.5.7
Server Version: v1.26.3
```

### Start the MicroK8s Kubernetes dashboard

This MicroK8s Kubernetes dashboard variant is non-blocking and can be used in pipelines and
scripts. It will automatically enable the dashboard addon:

```sh
make microk8s-dashboard
```

The output will contain the URL to the Kubernetes dashboard in addition to a token that can be used
to authenticate to the service. For example:

```sh title="Sample Kubernetes dashboard URL and token."
...
### Kubernetes dashboard address forwarded to: https://192.168.1.211:19443
### Kubernetes dashboard log output can be found at .makester/microk8s-dashboard.out
2023-04-09 13:57:19 logga [INFO]: Checking host:port 192.168.1.211:19443 MicroK8s Kubernetes dashboard ...
2023-04-09 13:57:20 logga [INFO]: Port 19443 ready
### Login to the MicroK8s Kubernetes dashboard with following token:
eyJhbGciOiJSUzI1NiIsImtpZCI6InlBTFNTTnpVQV8yQnBEeWh4MUNSc1lRZnZrWkZBVnZwVlAweHhMSS00ZlUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJtaWNyb2s4cy1kYXNoYm9hcmQtdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImFiNDM0N2NkLTZmZTMtNGNlMi05YWY2LTFjZmE5MDM3YzdlZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkZWZhdWx0In0.rpQofpXupJP9Dyk4vEWu1C_SivfDZXAXrCjU_TfsQ3MewjEj18PM43WVrodQ6fBounnt0HpFKiD9y6ImGqRipHz4Xmzd1gNEJp8fJydsOgYT42YnUKwMMHYFSQPQAxWVphL9B8xfNv9okFGv8DoeiXfSS2mA-jZtUPexHBB474D7yNz5lfwJQh1o7qGj3q0w7qMJibmM0lCE2Om2Eloar1QlV188YExab8l1RYG3RCMWcRWprGsYuuPGV4CDAjeK1ediiH-OzXmT5e8qIaVkHbUgvZZUObQ8GDYoeWMETHBj6nqVtRHOGuBvsxO6IhHTiC09EZasiR4zlYJHJtUHhA
```

Enter the token at the Kubernetes dashboard login screen:
![Kubernetes dashboard login](../../assets/images/kubernetes_dashboard_login.png)

### Enable the Kubernetes dashboard addon

See for [Addon: dashboard](https://microk8s.io/docs/addon-dashboard){target="\_blank"} for more information:

```sh
make microk8s-addon-dashboard
```

### Regenerate the MicroK8s Kubernetes dashboard authentication token

The MicroK8s Kubernetes dashboard will timeout the login after a period of inactivity. Regenerate
the token with:

```sh
make microk8s-dashboard-creds
```

### Start the MicroK8s Kubernetes dashboard proxy

This is a CLI-blocking variant of `make microk8s-dashboard`. Use `Ctrl-C` to terminate.

See [microk8s dashboard-proxy](https://microk8s.io/docs/command-reference#heading--microk8s-dashboard-proxy){target="\_blank"}
for more information:

```sh
make microk8s-dashboard-proxy
```

### List active namespaces in the Kubernetes cluster

This `kubectl` command lists the current active namespaces:

```sh
make microk8s-namespaces
```

## Variables

### `MICROK8S_DASHBOARD_PORT`

The MicroK8s Kubernetes dashboard port (default `<19443>`).

______________________________________________________________________

[top](#microk8s)
