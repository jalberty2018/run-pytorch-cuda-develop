# Build FlashAttention 2 Wheel

## Official

- [Github](https://github.com/Dao-AILab/flash-attention)

## RTX 30xx, A40, RTX 40xx, L40S, H100, Hopper, RTX 50xx, Blackwell

```bash
export FLASH_ATTENTION_FORCE_BUILD=TRUE
export FLASH_ATTN_CUDA_ARCHS=“80;90;120”
export MAX_JOBS=8
export NVCC_THREADS=4
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

## Build wheel (100 Gb RAM)

```bash
pip wheel . —no-build-isolation -w /tmp/wheels
```

## Install & Check

```bash
cd /workspace/build
pip install /workspace/flash-attention/dist/flash_attn-2.*.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])
