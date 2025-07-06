# pytorch-cuda-ubuntu-develop
FROM ls250824/pytorch-cuda-ubuntu-develop:05072025 AS base

# Workspace for installation
WORKDIR /

# code server web using environment variable PASSWORD

RUN curl -fsSL https://code-server.dev/install.sh | sh

# Civitai downloader using environment variable CIVITAI_TOKEN
COPY --chmod=755 civitai_environment.py /usr/local/bin/civitai

# Hugginface-cli comfy-cli
RUN pip3 install --no-cache-dir --upgrade huggingface_hub

# Development tools
RUN pip3 install --no-cache-dir --upgrade triton setuptools wheel build pytest

# README
COPY --chmod=644 README.md /README.md

# Build
COPY --chmod=644 build/ /build

# On Workspace
COPY --chmod=755 start.sh onworkspace/readme-on-workspace.sh onworkspace/build-on-workspace.sh / 

# Workspace
WORKDIR /workspace

# Port for code-server
EXPOSE 9000

# Start Server
CMD [ "/start.sh" ]
