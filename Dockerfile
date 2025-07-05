# pytorch-cuda-ubuntu-develop
FROM ls250824/pytorch-cuda-ubuntu-develop:05072025 AS base

# Workspace for installation
WORKDIR /

# code server web using environment variable PASSWORD

RUN curl -fsSL https://code-server.dev/install.sh | sh

# Civitai downloader using environment variable CIVITAI_TOKEN
COPY --chmod=755 civitai_environment.py /usr/local/bin/civitai

# Hugginface using environment variable HF_TOKEN
RUN pip3 install --no-cache-dir -U "huggingface_hub[cli]"

# Development tools
RUN pip3 install --no-cache-dir --upgrade triton setuptools wheel build pytest

# README
COPY --chmod=644 README.md /README.md

# On Workspace
COPY --chmod=755 start.sh onworkspace/readme-on-workspace.sh / 

# --- Base ---

# Workspace
WORKDIR /workspace

# Port for code-server
EXPOSE 9000

# Start Server
CMD [ "/start.sh" ]
