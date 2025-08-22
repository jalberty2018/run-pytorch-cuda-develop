# Build FlashAttention 2 Wheel

## Official

- [Github](https://github.com/thu-ml/SageAttention)


## Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
git checkout b7d29fb3b79f0b78b1c369a52aaa6628dabfb0d7 # 2.7.2 release
```

## Clean

```bash
rm -rf build/ dist/ *.egg-info
```

## Build wheel

```bash
MAX_JOBS=4 python setup.py bdist_wheel
```

## Build & install wheel

```
python setup.py install  # or pip install -e .
```

## Install & Check

```bash
pip install dist/flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl
python test_flash.py
```
- output = torch.Size([2, 4, 128, 64])

## Build FlashAttention 3 Wheel (Hopper architecture)

## Official

- [Github](https://github.com/thu-ml/SageAttention)

## Clone

```bash
git clone https://github.com/Dao-AILab/flash-attention.git --recursive
git checkout b7d29fb3b79f0b78b1c369a52aaa6628dabfb0d7
cd hopper
```

## Clean

```bash
rm -rf build/ dist/ *.egg-info
```

## Build wheel

```bash
python setup.py bdist_wheel
```

## Build & install wheel

```
python setup.py install  # or pip install -e .
```

## Install & Check

```bash
pip install dist/flashattn_hopper-3.0.0b1-cp311-cp311-linux_x86_64.whl
python test_flash.py
```

- output = torch.Size([2, 4, 128, 64])
