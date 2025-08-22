# radial-attention

## Official

[radial-attention](https://github.com/mit-han-lab/radial-attention)
[sparse-attention](https://github.com/Radioheading/Block-Sparse-SageAttention-2.0/tree/9d1e11b65f4dcec1d62dadfd7e1da437e251711c)

## Clone

```bash
git clone git@github.com:mit-han-lab/radial-attention --recursive
cd radial-attention/third_party/sparse_sageattn_2
```
## Clean

```bash
rm -rf build/ dist/ *.egg-info
```

## Build wheels

```bash
python -m build --no-isolation --wheel
ls -la dist/
```

## Build & install wheel

```bash
pip install --no-build-isolation --verbose .
```

## Install & Check

```bash
pip install dist/
python test_radial-attention.py
```

