# Build FlashAttention 2 Wheel

## Official

- [Github](https://github.com/Dao-AILab/flash-attention)

## A40, L40S

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9"
export USE_NINJA=1
```

## Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
```

## Clean

```bash
cd flash-attention/
rm -rf build/ dist/ *.egg-info
```

## Build wheel

```bash
MAX_JOBS=4 python -m build --wheel --no-isolation
```

## Install & Check

```bash
cd /workspace/build
pip install /workspace/flash-attention/dist/flash_attn-2.*.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])
