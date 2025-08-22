
# Build SageAttention2++ Wheel

## Official

- [Github](https://github.com/thu-ml/SageAttention)

## Clone

```bash
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
```

## Clean

```bash
rm -rf build/ dist/ *.egg-info
```

## Build wheel

```bash
MAX_JOBS=16 python -m build --wheel --no-isolation
```

## Install & Check

```bash
pip install dist/sageattention-2.x.x-cp311-cp311-linux_x86_64.whl
python test_sage.py
```

- output = torch.Size([2, 4, 128, 64])
