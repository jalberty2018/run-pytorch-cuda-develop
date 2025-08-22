# run-pytorch-cuda-develop

## Software Repositories  

### Core  

- [Code Server](https://github.com/coder/code-server)
- [Jupyterlab](https://jupyter.org)
- [Jupyter Server](https://jupyter-server.readthedocs.io/en/latest/index.html)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)

## Setup

| Component | Version             |
|-----------|---------------------|
| OS        | Ubuntu 22.04 x86_64 |
| Python    | 3.11.x              |
| PyTorch   | 2.8.0               |
| NVCC      | 12.9                |
| Triton    | 3.x                 |


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

## 7z

### Add directory to encrypted archive

```bash
7z a output.7z /workspace/output/
```

### Extract directory from archive

```bash
7z x x.7z
```

## CivitAI

```bash
civitai "<dowload link>" /workspace
```

## Huggingface  

```bash
huggingface-cli download model model_name.safetensors --local-dir /workspace
huggingface-cli upload model /workspace/model.safetensors
```

## Apps

```bash
nvtop
htop
mc
nano
tmux
c++
nvcc
python
pip
ncdu
unzip
```
