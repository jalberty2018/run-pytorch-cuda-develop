# syntax=docker/dockerfile:1.7
FROM ls250824/pytorch-cuda-ubuntu-develop:10032026

# Ubuntu 24.x
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Cache directory for Hugging Face
ENV HF_HOME=/workspace/cache

# Workspace for installation
WORKDIR /

# Requirements
COPY --chmod=664 /requirements.txt /requirements.txt

# Code server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Development tools, 
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install \
    --break-system-packages \
    --root-user-action ignore \
    --no-cache-dir \
    -r requirements.txt

# Civitai downloader using environment variable CIVITAI_TOKEN
COPY --chmod=755 civitai_environment.py /usr/local/bin/civitai

# Build
COPY --chmod=644 build/ /build

# README
COPY --chmod=664 /documentation/README.md /README.md

# On Workspace
COPY --chmod=755 start.sh onworkspace/readme-on-workspace.sh onworkspace/build-on-workspace.sh / 

# Workspace
WORKDIR /workspace

# Port for code-server jupyter lab gradio
EXPOSE 9000 8888 7860

# Labels
LABEL org.opencontainers.image.title="Pytorch CUDA Devel + PyTorch Image" \
      org.opencontainers.image.description="Pytorch 12.10 CUDA 12.8.1 devel + code-server + Jupyter + Gradio + civitai CLI" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/run-pytorch-cuda-ubuntu-develop" \
      org.opencontainers.image.licenses="MIT"

# Test
RUN python -c "import torch, torchvision, torchaudio, triton; \
print(f'Torch: {torch.__version__}\\nTorchvision: {torchvision.__version__}\\nTorchaudio: {torchaudio.__version__}\\nTriton: {triton.__version__}\\nCUDA available: {torch.cuda.is_available()}\\nCUDA version: {torch.version.cuda}')"

# Start Server
CMD [ "/start.sh" ]
