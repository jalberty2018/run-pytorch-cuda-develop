# Compiler settings

## Build/Deployment environment

- CUDA 12.8 dev/runtime
- GPU architecture: L40S (Lovelace), H100 (Hopper)
- Python 3.11.x
- PyTorch 2.7.1

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

You can adjust MAX_JOBS if you hit out-of-memory during compile.

## Common prerequisites

Make sure you have these installed:

Optional (for specific GPU arch targets):

### For Hopper (H100)

```bash
export TORCH_CUDA_ARCH_LIST="8.9"
```

### For Lovelace (L40S)

```bash
export TORCH_CUDA_ARCH_LIST="8.9;9.0"
```
