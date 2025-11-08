# run-pytorch-cuda-develop

## Hardware provisioning

- [Runpod.io](https://runpod.io?ref=se4tkc5o)
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

## Available Images

### Pytorch 2.8 CUDA 12.9

```bash
docker pull ls250824/run-pytorch-cuda-develop:09102025
```

### Pytorch 2.9 CUDA 13.0

```bash
docker pull ls250824/run-pytorch-cuda-develop:05112025
```

### Pytorch 2.9 CUDA 12.8

```bash
docker pull ls250824/run-pytorch-cuda-develop:08112025
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