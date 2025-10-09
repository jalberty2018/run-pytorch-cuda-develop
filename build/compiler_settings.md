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

- [architecture](https://developer.nvidia.com/cuda-gpus)

| Hardware | SM |
|-------|------|
| A40 / A100 | 8.6 / 8.0 |
| L40 / L40S / 4090 | 8.9 |
| H100 / H200 / Grace Hopper | 9.0 |

### FOR A40,RTX A500,L40S

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9"
```

### For Hopper (H100, H200)

```bash
export TORCH_CUDA_ARCH_LIST="9.0"
```


