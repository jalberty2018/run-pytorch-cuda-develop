# Flashinfer

## Official

[flashinfer](https://docs.flashinfer.ai/installation.html)

## Clone

```bash
git clone https://github.com/flashinfer-ai/flashinfer.git --recursive
cd flashinfer
```

## Clean

```bash
rm -rf build/ dist/ *.egg-info
```

## Build wheel JIT

```bash
cd flashinfer
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
python test_flashinfer.py
```

- output = torch.Size([7, 64, 128])
