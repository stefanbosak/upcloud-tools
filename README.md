<div align="center">

# ☁️ UpCloud Cloud Tools

**UpCloud ecosystem CLI tools (Hardened)**

[![build_status_badge](../../actions/workflows/docker-image-native-multiplatform-pipeline.yaml/badge.svg?branch=main)](.github/workflows/docker-image-native-multiplatform-pipeline.yaml)
[![UpCloud](https://img.shields.io/badge/UpCloud-1BC5BD?style=flat-square)](https://upcloud.com/)

</div>

---

## 📦 Latest Build

<!-- VERSION_INFO_START -->
| Component | Version |
|-----------|---------|
| **Ansible** | [`v2.21.2`](https://github.com/ansible/ansible/releases/tag/v2.21.2) |
| **cert-manager CLI** | [`v2.5.0`](https://github.com/cert-manager/cmctl/releases/tag/v2.5.0) |
| **Helm** | [`v4.2.3`](https://github.com/helm/helm/releases/tag/v4.2.3) |
| **K9s** | [`v0.51.0`](https://github.com/derailed/k9s/releases/tag/v0.51.0) |
| **Kops** | [`v1.36.0`](https://github.com/kubernetes/kops/releases/tag/v1.36.0) |
| **Kubectl** | [`v1.37.0-beta.0`](https://github.com/kubernetes/kubernetes/releases/tag/v1.37.0-beta.0) |
| **Kustomize** | [`5.8.1`](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize/v5.8.1) |
| **SwarmCLI** | [`v1.13.0-rc4`](https://github.com/Eldara-Tech/swarmcli/releases/tag/v1.13.0-rc4) |
| **Terraform** | [`1.16.0-alpha20260715`](https://github.com/hashicorp/terraform/releases/tag/v1.16.0-alpha20260715) |
| **Terragrunt** | [`v1.1.1`](https://github.com/gruntwork-io/terragrunt/releases/tag/v1.1.1) |
| **UpCloud CLI** | [`v3.34.0`](https://github.com/UpCloudLtd/upcloud-cli/releases/tag/v3.34.0) |

> 🔄 Last updated: 2026-07-21T22:48:53+02:00 · [Build #3](https://github.com/stefanbosak/upcloud-tools/actions/runs/29938963444)
<!-- VERSION_INFO_END -->

---

## 📋 Overview

This repository provides a fully automated preparation of <span style="color: #0969da;">**containerized**</span> [UpCloud](https://upcloud.com/) environment using <span style="color: #1a7f37;">**Docker-in-Docker**</span> architecture.

### Covered CLI tools

| Tool | Description |
|------|-------------|
| [Ansible CLI](https://docs.ansible.com/ansible/latest/command_guide/command_line_tools.html) | <span style="color: #8250df;">Configuration management and automation</span> |
| [UpCloud CLI](https://github.com/UpCloudLtd/upcloud-cli/) | <span style="color: #8250df;">Official UpCloud command-line interface (upctl)</span> |
| [cert-manager CLI](https://github.com/cert-manager/cmctl/) | <span style="color: #d73a49;">cert-manager CLI</span> |
| [CNPG CLI](https://github.com/cloudnative-pg/cloudnative-pg/) | <span style="color: #d73a49;">CloudNativePG CLI</span> |
| [Docker CLI](https://docker.com) | <span style="color: #d73a49;">Container management CLI</span> |
| [HELM CLI](https://helm.sh/docs/helm/) | <span style="color: #0969da;">Kubernetes package manager</span> |
| [kops CLI](https://kops.sigs.k8s.io/) | <span style="color: #0969da;">Kubernetes cluster management</span> |
| [kubectl CLI](https://kubernetes.io/docs/reference/kubectl/) | <span style="color: #0969da;">Kubernetes command-line tool</span> |
| [k9s CLI](https://k9scli.io/) | <span style="color: #0969da;">Terminal UI for Kubernetes</span> |
| [SwarmCLI](https://github.com/Eldara-Tech/swarmcli) | <span style="color: #0969da;">Terminal UI for Docker Swarm</span> |
| [Terraform CLI](https://developer.hashicorp.com/terraform/cli) | <span style="color: #1a7f37;">Infrastructure as Code tool</span> |
| [Terragrunt CLI](https://terragrunt.gruntwork.io/) | <span style="color: #1a7f37;">Terraform wrapper for DRY configurations</span> |

> [!NOTE]
> Every script and file is reasonably well commented and relevant details can be found there.

> [!IMPORTANT]
> Check details before taking any action.

> [!CAUTION]
> User is responsible for any modification and execution of any parts from this repository.

---

## ⚡ Zero Effort Approach

GitHub Actions workflow file covers all necessary activities which are fully automated in GitHub (re-using Docker container approach as base for automation):

- <span style="color: #1a7f37;">Gathering and propagating latest available tools versions to Docker preparation process</span>
- <span style="color: #0969da;">Building Docker hardened image</span>

---

## 🐳 Docker Container Approach

Docker build wrapper script covers creation of a container built from a multistage Dockerfile using parallel execution of several builders to speed up preparation. Generated image contains all mentioned tools with pre-enabled Bash completions. Docker run wrapper simplifies application execution.

| File | Description |
|------|-------------|
| [`Dockerfile`](Dockerfile) | <span style="color: #0969da;">Recipe for preparation of Docker container</span> |
| [`.docker`](.docker) | <span style="color: #8250df;">Directory for configuration data persistency (can be mapped into container)</span> |
| [`.config`](.config) | <span style="color: #8250df;">Directory for UpCloud CLI configuration data persistency (can be mapped into container)</span> |

### 🏗️ Container Images

| Registry | Network Support | Pull Command |
|----------|----------------|--------------|
| [**DockerHub CR**](https://hub.docker.com/r/developmententity/upcloud-tools) | <span style="color: #1a7f37;">IPv4 & IPv6</span> | `docker pull developmententity/upcloud-tools:initial` |
| [**GitHub CR**](https://github.com/users/stefanbosak/packages/container/package/upcloud-tools) | <span style="color: #8250df;">IPv4 only</span> | `docker pull ghcr.io/stefanbosak/upcloud-tools:initial` |

---

## 🌍 UpCloud Environment

UpCloud can be accessed via the upcloud-tools container which is automatically generated and available within ghcr.io. The dedicated `run.sh` script pulls and runs the up-to-date container.

Configure credentials for `upctl` (recommended: an API token) via one of the following, in order of precedence:

```bash
# 1. environment variable (recommended for containers)
export UPCLOUD_TOKEN="<your-api-token>"

# 2. config file (default ~/.config/upctl.yaml, mapped from this repo's .config directory)
cat <<EOF > .config/upctl.yaml
token: "<your-api-token>"
EOF

# 3. username/password environment variables (legacy fallback)
export UPCLOUD_USERNAME="<your-username>"
export UPCLOUD_PASSWORD="<your-password>"
```

API access is configured in the UpCloud Hub, on the [Account page](https://hub.upcloud.com/account/overview) for the main account, or on the [Permissions tab](https://hub.upcloud.com/people/permissions) of the People page for sub-accounts. A dedicated sub-account with API-only permissions is recommended.

Verify access and fetch a Managed Kubernetes (UKS) cluster kubeconfig, if needed:

```bash
# verify access, print account balance and resource limits
upctl account show

# list clusters, then merge the chosen cluster's kubeconfig into ~/.kube/config
upctl kubernetes list
upctl kubernetes config <UUID/Name> --output yaml --write ~/.kube/config
```

> [!NOTE]
> `upctl` (unlike `otc-cli`) covers day-2 operations natively across most UpCloud resources — servers, networks, storage, managed databases, Kubernetes (UKS) clusters, and object storage credentials. See the [command reference](https://upcloudltd.github.io/upcloud-cli/latest/commands_reference/upctl/) for the full list.

---

<div align="center">

<span style="color: #8250df;">**Made with ❤️ for ☁️ UpCloud ecosystem and 🔒 security**</span>

</div>
