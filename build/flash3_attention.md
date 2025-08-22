
# Build FlashAttention 3 Wheel (Hopper architecture)

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
pip install dist/flashattn_hopper-3.x.x-cp311-cp311-linux_x86_64.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])
