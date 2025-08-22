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

## Fast compilation for L40S

### Ada Lovelace (L40S) compute capability
export TORCH_CUDA_ARCH_LIST="8.9"

### optional speed-ups
export USE_NINJA=1
export MAX_JOBS=$(nproc)

### big win if you have it installed
export CXX="ccache g++"          # or just g++ if ccache not installed
export CCACHE_DIR=/workspace/.ccache
export CCACHE_MAXSIZE=10G

## Common prerequisites

### For Hopper (H100)

```bash
export TORCH_CUDA_ARCH_LIST="8.9"
```

### For Lovelace (L40S)

```bash
export TORCH_CUDA_ARCH_LIST="8.9;9.0"
```

### For L40S an RTX A5000

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9"
```
