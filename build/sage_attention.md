
# Build SageAttention2++ Wheel

## Official

- [Github](https://github.com/thu-ml/SageAttention)

## A40, L40S

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9"
export CMAKE_BUILD_PARALLEL_LEVEL=16
export USE_NINJA=1
```

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
cd /workscpace/build
pip install /workspace/SageAttention/dist/sageattention-2.*.whl
python test_sage.py
```

- output = torch.Size([2, 4, 128, 64])