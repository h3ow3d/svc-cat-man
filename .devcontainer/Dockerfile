FROM hashicorp/terraform:1.10

# Install wget and necessary packages
RUN apk add --no-cache \
    wget \
    tar \
    bash \
    git \
    python3 \
    py3-pip \
    pipx \
    cargo \
    rust \
    aws-cli

# Ensure pipx's binary directory is in PATH
ENV PATH="/root/.local/bin:$PATH"

# Install Go
RUN curl -sL https://go.dev/dl/go1.23.4.linux-amd64.tar.gz \
    | tar -C /usr/local -xzf -

# Set Go environment variables
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/go"
RUN mkdir -p /go/bin
ENV PATH="/go/bin:$PATH"

# Install tf-summarize
RUN /usr/local/go/bin/go install github.com/dineshba/tf-summarize@latest

# Install pre-commit & cfn-lint using pipx
RUN pipx install pre-commit cfn-lint tflint

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh \
    | bash

# Verify installations
RUN terraform --version && go version && /go/bin/tf-summarize --help

# Set up pre-commit hooks (initialize a temporary Git repository)
WORKDIR /workspace

RUN git init \
    && pre-commit install --hook-type commit-msg \
    && pre-commit install \
    && rm -rf .git

# Override entrypoint
ENTRYPOINT ["/bin/bash"]
