# Build SageAttention 2++ Wheel — Ampere + Ada + Blackwell

## Target Environment

- Ubuntu 24.04
- PyTorch 2.10
- CUDA 12.8
- NVIDIA Ampere — SM86
- NVIDIA Ada Lovelace — SM89
- NVIDIA Blackwell — SM120
- Build environment contains `nvcc`
- Runtime environment does **not** require `nvcc`
- Target: ComfyUI runtime

## Official

- [GitHub](https://github.com/thu-ml/SageAttention)

## Supported GPU Architectures

| Architecture | Compute Capability | Examples |
|---|---:|---|
| Ampere | SM86 | RTX 3090, RTX A5000, RTX A6000, A40 |
| Ada Lovelace | SM89 | RTX 4090, RTX 6000 Ada, L40, L40S |
| Blackwell | SM120 | RTX 5090, RTX 5080, RTX 5070 Ti |

## Verify Build Environment

```bash
python - <<'PY'
import torch

print("PyTorch:", torch.__version__)
print("PyTorch CUDA:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name())
    print("Compute capability:", torch.cuda.get_device_capability())
PY

nvcc --version
```

For an RTX 5090 build machine the expected compute capability is:

```text
(12, 0)
```

CUDA 12.8 or newer is required to compile the Blackwell SM120 target.

## Configuration

Compile native CUDA kernels for Ampere, Ada Lovelace and Blackwell:

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"

export MAX_JOBS=16
export EXT_PARALLEL=4
export NVCC_APPEND_FLAGS="--threads 8"

export CMAKE_BUILD_PARALLEL_LEVEL=16
export USE_NINJA=1
```

Verify:

```bash
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"
```

Expected:

```text
TORCH_CUDA_ARCH_LIST=8.6;8.9;12.0
```

Do not rely on automatic GPU detection when building a wheel intended for multiple GPU generations.

When compiling on an RTX 5090, automatic detection could otherwise result in a Blackwell-only build.

## Dependencies

```bash
python -m pip install --upgrade pip

pip install \
    "packaging>=21" \
    "wheel>=0.38" \
    "setuptools>=62" \
    "build>=1.2" \
    ninja
```

## Clone

```bash
cd /workspace

git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
```

Optionally record the exact SageAttention revision used:

```bash
git rev-parse HEAD
```

## Clean

Remove previous build artifacts before compiling:

```bash
rm -rf \
    build/ \
    dist/ \
    *.egg-info \
    sageattention/*.so
```

## Build Wheel

```bash
MAX_JOBS=16 \
EXT_PARALLEL=4 \
NVCC_APPEND_FLAGS="--threads 8" \
python -m build --wheel --no-isolation
```

The resulting wheel will be created in:

```text
/workspace/SageAttention/dist/
```

Example:

```text
sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
```

The exact Python ABI tag depends on the Python version used for compilation.

## Inspect Wheel

```bash
ls -lh dist/
```

Check that the compiled extensions are included:

```bash
unzip -l dist/sageattention-*.whl | grep '\.so'
```

The CUDA extensions are compiled into the wheel.

Therefore, the final ComfyUI runtime environment does **not** require:

```text
nvcc
CUDA development toolkit
CUDA headers
build-essential
ninja
```

The NVIDIA driver and the CUDA runtime required by PyTorch are still necessary.

## Install in ComfyUI Runtime

Install the generated wheel:

```bash
pip install /workspace/SageAttention/dist/sageattention-2.*.whl
```

The runtime environment should match the build environment as closely as possible:

```text
Ubuntu 24.04
same Python major/minor version
PyTorch 2.10.x
PyTorch CUDA 12.8 / cu128
x86_64
```

A CUDA compiler is not required in the runtime container.

## Import Check

```bash
python - <<'PY'
import torch
import sageattention

print("PyTorch:", torch.__version__)
print("PyTorch CUDA:", torch.version.cuda)
print("GPU:", torch.cuda.get_device_name())
print("Compute capability:", torch.cuda.get_device_capability())
print("SageAttention:", sageattention.__file__)
PY
```

## Functional Test

```bash
python - <<'PY'
import torch
from sageattention import sageattn

q = torch.randn(
    2,
    4,
    128,
    64,
    device="cuda",
    dtype=torch.float16,
)

k = torch.randn_like(q)
v = torch.randn_like(q)

output = sageattn(
    q,
    k,
    v,
    tensor_layout="HND",
    is_causal=False,
)

torch.cuda.synchronize()

print("GPU:", torch.cuda.get_device_name())
print("Compute capability:", torch.cuda.get_device_capability())
print("Output:", output.shape)
print("dtype:", output.dtype)
```

Expected:

```text
Output: torch.Size([2, 4, 128, 64])
```

## ComfyUI Runtime Validation

The same wheel should work on all three architectures:

```text
RTX 3090 / A40 / RTX A6000  -> SM86  Ampere
RTX 4090 / L40S             -> SM89  Ada Lovelace
RTX 5090                     -> SM120 Blackwell
```

Test the installed wheel with:

```bash
python - <<'PY'
import torch
from sageattention import sageattn

print("PyTorch:", torch.__version__)
print("CUDA runtime:", torch.version.cuda)
print("GPU:", torch.cuda.get_device_name())
print("SM:", torch.cuda.get_device_capability())

q = torch.randn(
    1,
    8,
    1024,
    64,
    device="cuda",
    dtype=torch.bfloat16,
)

o = sageattn(q, q, q)

torch.cuda.synchronize()

print("SageAttention OK:", o.shape)
PY
```

## Short Build Version

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"

export MAX_JOBS=16
export EXT_PARALLEL=4
export NVCC_APPEND_FLAGS="--threads 8"

export CMAKE_BUILD_PARALLEL_LEVEL=16
export USE_NINJA=1

cd /workspace

git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention

rm -rf build/ dist/ *.egg-info sageattention/*.so

python -m pip install --upgrade pip
pip install -U build ninja packaging wheel setuptools

python -m build --wheel --no-isolation
```

## Result

One SageAttention wheel containing native CUDA support for:

```text
SM86  -> Ampere
SM89  -> Ada Lovelace
SM120 -> Blackwell
```

Recommended architecture configuration:

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"
```

No `+PTX` target is required because all three target architectures are compiled explicitly into the wheel.