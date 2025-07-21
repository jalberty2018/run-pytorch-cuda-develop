[![Docker Image Version](https://img.shields.io/docker/v/ls250824/run-pytorch-cuda-develop)](https://hub.docker.com/r/ls250824/run-pytorch-cuda-develop)

# run-pytorch-cuda-develop

## Hardware provisioning

- [Runpod.io](https://runpod.io?ref=se4tkc5o)
- GPU

## Software Repositories  

### Core  

- [Code Server](https://github.com/coder/code-server)
- [Jupyterlab](https://jupyter.org)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)

## Setup

| Component | Version             |
|-----------|---------------------|
| OS        | Ubuntu 22.04 x86_64 |
| Python    | 3.11.x              |
| PyTorch   | 2.7.1               |
| NVCC      | 12.8                |
| Triton    | 3.x                 |

## Available Images

### Base Images 

#### ls250824/pytorch-cuda-ubuntu-develop
	
[![Docker Image Version](https://img.shields.io/docker/v/ls250824/pytorch-cuda-ubuntu-develop)](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-develop)

### Custom Build: 

```bash
docker pull ls250824/run-pytorch-cuda-develop:<version>
```

## Connection options 

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