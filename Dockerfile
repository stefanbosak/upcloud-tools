# user in container
ARG CONTAINER_USER=user
ARG CONTAINER_GROUP=user

ARG CONTAINER_USER_ID=1000
ARG CONTAINER_GROUP_ID=1000

# set location of workspace directory
# (temporary space within container image)
ARG WORKSPACE_ROOT_DIR="/home/${CONTAINER_USER}"

# Debian release and options
ARG DEBIAN_RELEASE=trixie-debian13-dev
ARG DEBIAN_FRONTEND=noninteractive

# ansible CLI tools versions
ARG ANSIBLE_CLI_VERSION=v2.21.1

# cert-manager CLI version
ARG CM_CTL_CLI_VERSION=v2.5.0

# Helm version
ARG HELM_CLI_VERSION=v4.2.2

# kubectl version
ARG K9S_CLI_VERSION=v0.51.0

# kops version
ARG KOPS_CLI_VERSION=v1.36.0-beta.1

# kubectl version
ARG KUBECTL_CLI_VERSION=v1.36.2

# Kustomize version
ARG KUSTOMIZE_CLI_VERSION=5.8.1

# SwarmCLI version
ARG SWARM_CLI_VERSION=v1.12.0

# Terraform version
ARG TERRAFORM_CLI_VERSION=1.16.0-alpha20260617

# Terragrunt version
ARG TERRAGRUNT_CLI_VERSION=v1.1.0-rc2

# UpCloud CLI version
ARG UPCLOUD_CLI_VERSION=v3.34.0

# container as builder for preparing UpCloud cloud tools
FROM dhi.io/debian-base:${DEBIAN_RELEASE} AS upcloud-tools-builder

LABEL stage="upcloud-tools-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tools" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tools" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG DEBIAN_FRONTEND

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install required packages and additional applications
RUN apt-get update && \
    apt-get -y --no-install-recommends install ca-certificates binutils curl unzip && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*"

# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-ansible-cli-builder

LABEL stage="upcloud-tools-ansible-cli-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool ansible" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool ansible" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG ANSIBLE_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download and install ansible tool
RUN apt-get -y --no-install-recommends install python-is-python3 python3-pip && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*"
RUN python3 -m pip install --break-system-packages "https://github.com/ansible/ansible/archive/refs/tags/${ANSIBLE_CLI_VERSION}.tar.gz"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-cm-builder

LABEL stage="upcloud-tools-cm-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool cert-manager CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool cert-manager CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG CM_CTL_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download cert-manager
ADD "https://github.com/cert-manager/cmctl/releases/download/${CM_CTL_CLI_VERSION}/cmctl_linux_${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/cmctl_linux_${TARGETARCH}"

# install cert-manager
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/cmctl_linux_${TARGETARCH}" "/usr/local/bin/kubectl-cert_manager"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-cnpg-builder

LABEL stage="upcloud-tools-cnpg-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool CNPG CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool CNPG CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install kubectl CNPG plugin
RUN mkdir -p "/usr/local/bin/" && \
    curl -sSfL https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | \
    sh -s -- -b /usr/local/bin


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-helm-builder

LABEL stage="upcloud-tools-helm-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool HELM CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool HELM CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG HELM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download HELM archive file
ADD "https://get.helm.sh/helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install HELM
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" -C "/usr/local/bin" --strip-components 1 --no-anchored "helm"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-k9s-builder

LABEL stage="upcloud-tools-k9s-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool k9s CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool k9s CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG K9S_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download k9s CLI binary file
ADD "https://github.com/derailed/k9s/releases/download/${K9S_CLI_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install k9s
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/k9s_Linux_${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "k9s"


# container as builder for preparing kops UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-kops-builder

LABEL stage="upcloud-tools-kops-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool kops CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool kops CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KOPS_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://github.com/kubernetes/kops/releases/download/${KOPS_CLI_VERSION}/kops-${TARGETOS}-${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/"

# install kubectl
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/kops-${TARGETOS}-${TARGETARCH}" "/usr/local/bin/kops"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-kubectl-builder

LABEL stage="upcloud-tools-kubectl-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool kubectl CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool kubectl CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KUBECTL_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://dl.k8s.io/release/${KUBECTL_CLI_VERSION}/bin/linux/${TARGETARCH}/kubectl" "${WORKSPACE_ROOT_DIR}/"

# install kubectl
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/kubectl" "/usr/local/bin/"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-kustomize-builder

LABEL stage="upcloud-tools-kustomize-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool kustomize CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool kustomize CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KUSTOMIZE_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kustomize archive
ADD "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_CLI_VERSION}/kustomize_v${KUSTOMIZE_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install kustomize
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/kustomize_v${KUSTOMIZE_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "kustomize"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-swarmcli-builder

LABEL stage="upcloud-tools-swarmcli-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool SwarmCLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool SwarmCLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG SWARM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install SwarmCLI
RUN mkdir -p "/usr/local/bin/" && \
    curl -fsSL https://swarmcli.io/install.sh | \
    sh -s -- ce /usr/local/bin "${SWARM_CLI_VERSION}"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-terraform-builder

LABEL stage="upcloud-tools-terraform-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool terraform" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool terraform" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG TERRAFORM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download TF CLI archive file
ADD "https://releases.hashicorp.com/terraform/${TERRAFORM_CLI_VERSION}/terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" "${WORKSPACE_ROOT_DIR}/"

# install TF CLI binary
RUN mkdir -p "/usr/local/bin/" && unzip "terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" -d "/usr/local/bin/"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-terragrunt-builder

LABEL stage="upcloud-tools-terragrunt-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool terragrunt CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool terragrunt CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG TERRAGRUNT_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_CLI_VERSION}/terragrunt_${TARGETOS}_${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/"

# install terragrunt CLI
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/terragrunt_${TARGETOS}_${TARGETARCH}" "/usr/local/bin/terragrunt"


# container as builder for preparing UpCloud cloud tools
FROM upcloud-tools-builder AS upcloud-tools-upcloud-cli-builder

LABEL stage="upcloud-tools-upcloud-cli-builder" \
      description="Debian-based container builder for preparing UpCloud cloud tool UpCloud CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing UpCloud cloud tool UpCloud CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG UPCLOUD_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download and install UpCloud CLI (https://github.com/UpCloudLtd/upcloud-cli)
#
# NOTE: unlike most other tools here, upcloud-cli only ships tar.gz/zip
# archives per release (no bare binary asset), and its release asset arch
# naming ("x86_64"/"arm64") differs from Docker's TARGETARCH ("amd64"/"arm64"),
# so the mapping below is required before downloading.
RUN case "${TARGETARCH}" in \
      amd64) UPCLOUD_CLI_ARCH="x86_64" ;; \
      arm64) UPCLOUD_CLI_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -fsSL -o "${WORKSPACE_ROOT_DIR}/upcloud-cli.tar.gz" \
      "https://github.com/UpCloudLtd/upcloud-cli/releases/download/${UPCLOUD_CLI_VERSION}/upcloud-cli_${UPCLOUD_CLI_VERSION#v}_${TARGETOS}_${UPCLOUD_CLI_ARCH}.tar.gz" && \
    mkdir -p "/usr/local/bin/" && \
    tar -xvf "${WORKSPACE_ROOT_DIR}/upcloud-cli.tar.gz" -C "/usr/local/bin" --no-anchored "upctl" && \
    chmod 0755 "/usr/local/bin/upctl"


FROM scratch AS upcloud-tools-binaries-aggregator

# transfer tools from builders
COPY --from=upcloud-tools-ansible-cli-builder "/usr/local/bin" "/usr/local/bin"
COPY --from=upcloud-tools-ansible-cli-builder "/usr/local/lib/" "/usr/local/lib"
COPY --from=upcloud-tools-cm-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-cnpg-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-helm-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-k9s-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-kops-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-kubectl-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-kustomize-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-swarmcli-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-terraform-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-terragrunt-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=upcloud-tools-upcloud-cli-builder "/usr/local/bin/" "/usr/local/bin/"


# container as final image for providing UpCloud cloud tools
FROM dhi.io/debian-base:${DEBIAN_RELEASE} AS upcloud-tools-image

LABEL stage="upcloud-tools-image" \
      description="Debian-based container with UpCloud cloud tools" \
      org.opencontainers.image.description="Debian-based container with UpCloud cloud tools" \
      org.opencontainers.image.url=https://github.com/stefanbosak/upcloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/upcloud-tools

ARG TARGETOS
ARG TARGETARCH

# user in container
ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ARG DEBIAN_FRONTEND

ARG HOME_ROOT_DIR="/home/${CONTAINER_USER}"

WORKDIR "${HOME_ROOT_DIR}"

RUN mkdir -p "/usr/local/bin/" && \
    apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      bash-completion \
      bc \
      ca-certificates \
      curl \
      dnsutils \
      git \
      gnupg \
      gzip \
      iproute2 \
      iputils-ping \
      jq \
      kmod \
      lsof \
      openssh-client \
      pigz \
      procps \
      psmisc \
      python-is-python3 \
      python3-venv \
      python3-argcomplete \
      ripgrep \
      rsync \
      socat \
      unzip \
      wget \
      whois \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install DiD (Docker in Docker)
# - DinD via QEMU on ARM64 is not supported
#   (ARM64 requires ARM64 kernel from host system which is not present on AMD64 host)
RUN curl -fsSL https://test.docker.com | sh && \
    if ! getent group docker > /dev/null 2>&1; then \
      groupadd docker; \
    fi

# copy tools from aggregator
COPY --from=upcloud-tools-binaries-aggregator / /

# setup user and group
RUN if getent group "${CONTAINER_GROUP_ID}" > /dev/null; then \
      _existing_group="$(getent group "${CONTAINER_GROUP_ID}" | cut -d: -f1)"; \
      if [ "${_existing_group}" != "${CONTAINER_GROUP}" ]; then \
        groupmod -n "${CONTAINER_GROUP}" "${_existing_group}"; \
      fi; \
    else \
      groupadd --gid "${CONTAINER_GROUP_ID}" "${CONTAINER_GROUP}"; \
    fi \
    && if getent passwd "${CONTAINER_USER_ID}" > /dev/null; then \
         _existing_user="$(getent passwd "${CONTAINER_USER_ID}" | cut -d: -f1)"; \
         if [ "${_existing_user}" != "${CONTAINER_USER}" ]; then \
           if [ -d "/home/${_existing_user}" ]; then \
             mv "/home/${_existing_user}" "/home/${CONTAINER_USER}"; \
           fi; \
           usermod -d "${HOME_ROOT_DIR}" -l "${CONTAINER_USER}" "${_existing_user}"; \
         fi; \
       else \
         useradd \
           --uid "${CONTAINER_USER_ID}" \
           --gid "${CONTAINER_GROUP_ID}" \
           --groups "${CONTAINER_GROUP}" \
           -M -d "${HOME_ROOT_DIR}" \
           -s /bin/bash \
           "${CONTAINER_USER}"; \
       fi \
    && chown -R "${CONTAINER_USER}:${CONTAINER_GROUP}" "${HOME_ROOT_DIR}" \
    && usermod -aG docker "${CONTAINER_USER}" && \
# enable tools completions (required to run given tool to generate completion file content)
    ln -s /usr/local/bin/kubectl-cert_manager /usr/local/bin/cmctl && \
    cmctl completion bash > /usr/share/bash-completion/completions/cmctl && \
    ln -s /usr/local/bin/kubectl-cnpg /usr/local/bin/cnpgctl && \
    cnpgctl completion bash > /usr/share/bash-completion/completions/cnpgctl && \
    sed -i 's/kubectl-cnpg/cnpgctl/g' /usr/share/bash-completion/completions/cnpgctl && \
    helm completion bash > "/usr/share/bash-completion/completions/helm" && \
    k9s completion bash > "/usr/share/bash-completion/completions/k9s" && \
    kops completion bash > "/usr/share/bash-completion/completions/kops" && \
    kubectl completion bash > "/usr/share/bash-completion/completions/kubectl" && \
    cp "/usr/share/bash-completion/completions/kubectl" "/usr/share/bash-completion/completions/k" && \
    sed -i 's/kubectl/k/g' "/usr/share/bash-completion/completions/k" && \
    ln -s /usr/local/bin/kubectl /usr/local/bin/k && \
    kustomize completion bash > "/usr/share/bash-completion/completions/kustomize" && \
    upctl completion bash > "/usr/share/bash-completion/completions/upctl" && \
    echo "complete -C terraform terraform" > "/usr/share/bash-completion/completions/terraform" && \
    echo "complete -C terragrunt terragrunt" > "/usr/share/bash-completion/completions/terragrunt" && \
    activate-global-python-argcomplete

# container user and group
USER "${CONTAINER_USER}:${CONTAINER_GROUP}"

WORKDIR "${HOME_ROOT_DIR}"

RUN cp /etc/skel/.bashrc /etc/skel/.profile "${HOME_ROOT_DIR}"

# open shell
CMD ["bash"]
