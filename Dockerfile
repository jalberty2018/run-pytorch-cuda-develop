# pytorch-cuda-ubuntu-develop
FROM ls250824/pytorch-cuda-ubuntu-develop:22082025 AS base

# Workspace for installation
WORKDIR /

# Civitai downloader using environment variable CIVITAI_TOKEN
COPY --chmod=755 civitai_environment.py /usr/local/bin/civitai

# Build
COPY --chmod=644 build/ /build

# README
COPY --chmod=664 /documentation/README.md /README.md

# On Workspace
COPY --chmod=755 start.sh onworkspace/readme-on-workspace.sh onworkspace/build-on-workspace.sh / 

# code server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Update Development tools, 
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --root-user-action ignore --no-cache-dir \
	pip setuptools wheel build

# Install jupyterlab, gradio, hf
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --root-user-action ignore --no-cache-dir \
    jupyterlab gradio "huggingface_hub[cli]"

# Workspace
WORKDIR /workspace

# Cache directory for Hugging Face
ENV HF_HOME=/workspace/cache

# Port for code-server jupyter lab gradio
EXPOSE 9000 8888 7860

# Labels
LABEL org.opencontainers.image.title="CUDA Devel + PyTorch Image" \
      org.opencontainers.image.description="CUDA 12.9 devel + Ubuntu 22.04 + Python + code-server + Jupyter + Gradio + civitai CLI" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/run-pytorch-cuda-ubuntu-develop" \
      org.opencontainers.image.licenses="MIT"

# Test
RUN python -c "import torch, torchvision, torchaudio, triton; \
print(f'Torch: {torch.__version__}\\nTorchvision: {torchvision.__version__}\\nTorchaudio: {torchaudio.__version__}\\nTriton: {triton.__version__}\\nCUDA available: {torch.cuda.is_available()}\\nCUDA version: {torch.version.cuda}')"

# Start Server
CMD [ "/start.sh" ]
