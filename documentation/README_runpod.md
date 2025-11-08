# run-pytorch-cuda-develop

## Software Repositories  

### Core  

- [Code Server](https://github.com/coder/code-server)
- [Jupyterlab](https://jupyter.org)
- [Jupyter Server](https://jupyter-server.readthedocs.io/en/latest/index.html)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Nvidia CUDA](https://hub.docker.com/r/nvidia/cuda/tags?name=12)
- [Pytorch.org](https://pytorch.org)
- [Triton](https://triton-lang.org/main/index.html)

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