# Compiler settings

## Preliminary check

```bash
nvcc --version
python --version
pip --version
```

## Recommended compiler settings

- For 32 vCPU / 120 GB RAM nodes:

```bash
export MAX_JOBS=16
export CMAKE_BUILD_PARALLEL_LEVEL=16
```

### Speed-ups

```bash
export USE_NINJA=1
export MAX_JOBS=$(nproc)
```

## Common prerequisites

- [SM architecture](https://developer.nvidia.com/cuda-gpus)
- [Wikipedia](https://en.wikipedia.org/wiki/CUDA)

| Hardware | SM |
|-------|------|
| A100 | 8.0 |
| A40 / A5000 | 8.6 |
| L40 / L40S / RTX 4090 / RTX 6000 Ada | 8.9 |
| H100 / H200 / Grace Hopper | 9.0 |

### FOR A40,RTX A500,L40S

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9"
```

### For Hopper (H100, H200)

```bash
export TORCH_CUDA_ARCH_LIST="9.0"
```



