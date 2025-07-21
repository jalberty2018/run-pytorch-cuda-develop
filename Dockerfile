# pytorch-cuda-ubuntu-develop
FROM ls250824/pytorch-cuda-ubuntu-develop:21072025 AS base

# Workspace for installation
WORKDIR /

# Civitai downloader using environment variable CIVITAI_TOKEN
COPY --chmod=755 civitai_environment.py /usr/local/bin/civitai

# Build
COPY --chmod=644 build/ /build

# README
COPY --chmod=664 /documentation/README_runpod.md /README.md

# On Workspace
COPY --chmod=755 start.sh onworkspace/readme-on-workspace.sh onworkspace/build-on-workspace.sh / 

# Development tools & Hugginface-cli & jupyterlab
RUN pip3 install --no-cache-dir --upgrade huggingface_hub triton setuptools wheel build pytest jupyterlab gradio

# code server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Workspace
WORKDIR /workspace

# Port for code-server jupyter lab gradio
EXPOSE 9000 8888 7860

# Start Server
CMD [ "/start.sh" ]
