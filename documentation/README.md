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

### **Huggingface**  

```bash
export HF_TOKEN="xxxxx"
hf download model model_name.safetensors --local-dir /workspace/ComfyUI/models/diffusion_models/
hf upload model /workspace/model.safetensors
```

```bash
hf auth login --token xxxxx
```

## **CivitAI**  

```bash
export CIVITAI_TOKEN="xxxxx"
civitai_com <VERSION_ID> /workspace/ComfyUI/models/diffusion_models
civitai_com <VERSION_ID> /workspace/ComfyUI/models/loras
civitai_red <VERSION_ID> /workspace/ComfyUI/models/diffusion_models
civitai_red <VERSION_ID> /workspace/ComfyUI/models/loras
```

## 7z Compression  

### **Encrypt & Archive Output**  

```bash
7z a -p -mhe=on /workspace/output/output-minimax-x.7z /workspace/ComfyUI/output/
7z a -p -mhe=on -v800m /workspace/output/output-image-x.7z /workspace/ComfyUI/output/
```

### **Extract Archive**  

```bash
7z x x.7z
```

## Clean up  

```bash
rm -rf /workspace/output/ /workspace/input/ /workspace/ComfyUI/output/ /workspace/ComfyUI/input/ /workspace/ComfyUI/models/loras/
```

## Utilities  

```bash
nvtop      # GPU Monitoring
nvidia-smi # GPU information
htop       # Process Monitoring  
mc         # Midnight Commander (file manager)  
nano       # Text Editor
ncdu       # Clean Up
unzip      # uncompress
age        # public/private key encryption
7z         # Archiving
runpodctl  # runpod pod management
```

