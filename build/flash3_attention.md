
# Build FlashAttention 3 Wheel (Hopper architecture)

## H100, H200

```bash
export TORCH_CUDA_ARCH_LIST="9.0"
export USE_NINJA=1
```

## Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
cd hopper
```

## Clean

```bash
rm -rf build/ dist/ *.egg-info
```

## Build wheel

```bash
MAX_JOBS=4 python -m build --wheel --no-isolation
```

## Install & Check

```bash
cd /workspace/build
pip install /workspace/flash-attention/hopper/dist/flashattn_hopper-3.*.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])
