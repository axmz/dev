FROM mcr.microsoft.com/devcontainers/base:noble AS base
USER root
ENV HOME=/root
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    clang \
    clangd \
    lldb \
    cmake \
    valgrind \
    cppcheck \
    vim \
    tmux \
    lf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Zsh
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

COPY .zshrc /root/.zshrc
COPY .gitignore /root/.gitignore

FROM base AS devcontainer

# Go
ARG GO_VERSION=1.25.3
RUN curl -sSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
ENV CGO_ENABLED=0
RUN go install github.com/pilu/fresh@latest && \
    go install github.com/air-verse/air@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup component add rust-analyzer rust-src rustfmt clippy

# Node.js
ARG NVM_VERSION=0.40.3
ENV NVM_DIR="/root/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | PROFILE="${BASH_ENV}" bash
RUN bash -c 'source "$NVM_DIR/nvm.sh" && \
    nvm install node && \
    npm install -g yarn pnpm nodemon typescript'
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.zshrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.zshrc

CMD ["zsh"]
