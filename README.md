[![Docker Image Version](https://img.shields.io/docker/v/ls250824/run-pytorch-cuda-develop)](https://hub.docker.com/r/ls250824/run-pytorch-cuda-develop)

# run-pytorch-cuda-develop

## Synopsis

A streamlined setup for developing on high-performance hardware.  

- Authentication credentials set via secrets for:  
  - **Code server** authentication
  - **Jupyterlab** authentication
  - **Hugging Face** and **CivitAI** tokens for model access (mandatory).  

Ensure that the required environment variables and secrets are correctly set before running the pod.
See below for options.

## Hardware provisioning

- [Runpod.io](https://runpod.io/)
- GPU

## Software Repositories  

### Core  

- [Code Server](https://github.com/coder/code-server)
- [Jupyterlab](https://jupyter.org)
- [Jupyter Server](https://jupyter-server.readthedocs.io/en/latest/index.html)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Nvidia CUDA](https://hub.docker.com/r/nvidia/cuda/tags?name=12)
- [Pytorch.org](https://pytorch.org)
- [Triton](https://triton-lang.org/main/index.html)

## Setup

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.8.0`              |
| CUDA      | `12.9.1`             |
| Triton    | `2.4.x`               |
| nvcc      | `12.9.x`            |

## Available Images

### Base Images 

#### ls250824/pytorch-cuda-ubuntu-develop
	
[![Docker Image Version](https://img.shields.io/docker/v/ls250824/pytorch-cuda-ubuntu-develop)](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-develop)

### Custom Build: 

```bash
docker pull ls250824/run-pytorch-cuda-develop:<version>
```

## Settings

### Services

| Service         | Port          |
|-----------------|---------------| 
| **Code Server** | `9000` (HTTP) |
| **Jupyterlab**  | `8888` (HTTP) |
| **SSH/SCP**     | `22`   (TCP)  |
| **Gradio**      | `7860` (HTTP) |

### Authentication Tokens 

| Token        | Environment Variable |
|--------------|----------------------|
| Civitai      | `CIVITAI_TOKEN`      |
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |
| Jupyterlab   | `JUPYTERLAB_PASS`    |

### Sources

| Variable         | Description                      |
|------------------|----------------------------------|
| `SOURCE[1-50]` | source download links (compressed or plain) |

## Building the Docker Image 

### `build-docker.py` script options

| Option         | Description                                         | Default                |
|----------------|-----------------------------------------------------|------------------------|
| `--username`   | Docker Hub username                                 | Current user           |
| `--tag`        | Tag to use for the image                            | Today's date           |
| `--latest`     | If specified, also tags and pushes as `latest`      | Not enabled by default |

### Build & push Command

Run the following command to clone the repository and build the image:

```bash
git clone https://github.com/jalberty2018/run-pytorch-cuda-develop.git
cp run-pytorch-cuda-develop/build-docker.py ..

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

python build-docker.py \
--username=<your_dockerhub_username> \
--tag=<custom_tag> \ 
run-pytorch-cuda-develop
```

Note: If you want to push the image with the latest tag, add the --latest flag at the end.