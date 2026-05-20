FROM node:22-bookworm-slim

ARG USERNAME=ccode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
  git \
  gh \
  curl \
  wget \
  ca-certificates \
  openssh-client \
  gnupg2 \
  ripgrep \
  fd-find \
  jq \
  less \
  tree \
  nano \
  vim \
  zip \
  unzip \
  procps \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupmod -n ${USERNAME} node \
 && usermod -l ${USERNAME} -d /home/${USERNAME} -m node \
 && mkdir -p /workspace /home/${USERNAME}/.claude /home/${USERNAME}/.config \
 && chown ${USERNAME}:${USERNAME} /workspace /home/${USERNAME}/.claude /home/${USERNAME}/.config

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Organization-level settings
RUN mkdir -p /etc/claude-code
COPY managed-settings.json /etc/claude-code/managed-settings.json
COPY statusline.sh /etc/claude-code/statusline.sh
RUN chmod +x /etc/claude-code/statusline.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY --from=ghcr.io/astral-sh/uv:latest /uvx /usr/local/bin/uvx

USER ${USERNAME}
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
