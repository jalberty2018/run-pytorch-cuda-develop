[![Docker Image Version](https://img.shields.io/docker/v/ls250824/run-pytorch-cuda-develop)](https://hub.docker.com/r/ls250824/run-pytorch-cuda-develop)

# run-pytorch-cuda-develop

## Hardware provisioning

- [Runpod.io](https://runpod.io/)
- GPU

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
| **SSH/SCP**     | `22`   (TCP)  |

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
```

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

python3 build-docker.py \
--username=<your_dockerhub_username> \
--tag=<custom_tag> \ 
run-pytorch-cuda-develop
```

Note: If you want to push the image with the latest tag, add the --latest flag at the end.