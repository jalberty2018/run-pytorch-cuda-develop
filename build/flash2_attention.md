# Build FlashAttention 2 Wheel

## Official

- [Github](https://github.com/Dao-AILab/flash-attention)


git clone https://github.com/Dao-AILab/flash-attention.git --recursive
   33  ls
   34  cd flash-attention/
   35  ls
   36  rm -rf build/ dist/ *.egg-info
   37  pip install build wheel
   38  python -m build --wheel
   39  pip install build
   40  python -m build --wheel --no-isolation
   41  pip install dist/flash_attn-2.8.3-*.whl
   42  cd ..
   43  ls
   44  cd build
   45  python test_flash.py


## Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
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
pip install dist/flash_attn-2.x.x-cp311-cp311-linux_x86_64.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])

