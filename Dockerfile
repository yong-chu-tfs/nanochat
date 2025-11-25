# syntax=docker/dockerfile:1.6
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
    && apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        -o Dir::Cache::archives="/tmp" \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        python-is-python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

# Install uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -s /root/.local/bin/uv /usr/local/bin/uv

# Install Rust toolchain for the tokenizer extension
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && echo 'source /root/.cargo/env' >> /root/.bashrc

ENV PATH="/root/.cargo/bin:/root/.local/bin:${PATH}"

WORKDIR /workspace

# Copy project files
COPY . /workspace

# Create the virtual environment and install dependencies
RUN uv venv \
    && uv sync --extra gpu

ENV VIRTUAL_ENV=/workspace/.venv
ENV PATH="/workspace/.venv/bin:${PATH}"
ENV NANOCHAT_BASE_DIR="/workspace/.cache/nanochat"
RUN mkdir -p "$NANOCHAT_BASE_DIR"

CMD ["bash"]
