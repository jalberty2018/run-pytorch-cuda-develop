# Compile Flash- and SageAttention

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

## Build SageAttention2++ Wheel

### Official

- [Github](https://github.com/thu-ml/SageAttention)

### Clone

```bash
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
```

### Clean

```bash
rm -rf build/ dist/ *.egg-info
```

### Build wheel

```bash
python setup.py bdist_wheel
```

### Build & install wheel

```bash
python setup.py install  # or pip install -e .
```

### Install & Check

```bash
pip install dist/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl
python test_sage.py
```

- output = torch.Size([2, 4, 128, 64])

## Build FlashAttention 2 Wheel

### Official

- [Github](https://github.com/thu-ml/SageAttention)


### Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
git checkout b7d29fb3b79f0b78b1c369a52aaa6628dabfb0d7 # 2.7.2 release
```

### Clean

```bash
rm -rf build/ dist/ *.egg-info
```

### Build wheel

```bash
MAX_JOBS=4 python setup.py bdist_wheel
```

### Build & install wheel

```
python setup.py install  # or pip install -e .
```

### Install & Check

```bash
pip install dist/flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])

## Build FlashAttention 3 Wheel (Hopper architecture)

### Official

- [Github](https://github.com/thu-ml/SageAttention)

### Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
git checkout b7d29fb3b79f0b78b1c369a52aaa6628dabfb0d7
cd hopper
```

### Clean

```bash
rm -rf build/ dist/ *.egg-info
```

### Build wheel

```bash
python setup.py bdist_wheel
```

### Build & install wheel

```
python setup.py install  # or pip install -e .
```

### Install & Check

```bash
pip install dist/flashattn_hopper-3.0.0b1-cp311-cp311-linux_x86_64.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])
