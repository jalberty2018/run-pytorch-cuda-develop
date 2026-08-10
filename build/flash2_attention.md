# Build FlashAttention 2 Wheel — Ampere + Ada + Blackwell

## Target Environment

- Ubuntu 24.04
- Python 3.12
- PyTorch 2.10
- CUDA 12.8
- NVIDIA Ampere — SM86
- NVIDIA Ada Lovelace — SM89
- NVIDIA Blackwell — SM120
- Build environment contains `nvcc`
- Runtime environment does **not** require `nvcc`
- Target: ComfyUI runtime
- Architecture: x86_64

## Official

- [FlashAttention GitHub](https://github.com/Dao-AILab/flash-attention)

## Supported GPU Architectures

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere | 8.6 | `sm_86` | RTX 3090, RTX A5000, RTX A6000, A40 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40, L40S |
| Blackwell | 12.0 | `sm_120` | RTX 5090, RTX 5080, RTX 5070 Ti |

CUDA 12.8 or newer is required for compiling native SM120 Blackwell code.

---

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

For an RTX 5090 build machine, the expected compute capability is:

```text
(12, 0)
```

---

## Configuration

Compile for Ampere, Ada Lovelace and Blackwell:

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"
export CUDAARCHS="86;89;120"

export MAX_JOBS=8
export USE_NINJA=1
```

Verify:

```bash
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"
echo "CUDAARCHS=${CUDAARCHS}"
```

Expected:

```text
TORCH_CUDA_ARCH_LIST=8.6;8.9;12.0
CUDAARCHS=86;89;120
```

Explicitly specifying the architectures prevents the wheel from being limited to the GPU present in the build machine.

---

## Dependencies

```bash
python -m pip install --upgrade pip

pip install -U \
    build \
    ninja \
    packaging \
    wheel \
    setuptools
```

Verify Ninja:

```bash
ninja --version
```

---

## Clone

```bash
cd /workspace

git clone \
    https://github.com/Dao-AILab/flash-attention.git \
    --recursive

cd flash-attention
```

Record the exact revision:

```bash
git rev-parse HEAD
```

Also verify the FlashAttention version:

```bash
grep -E '^__version__|version=' setup.py | head
```

---

## Clean

Remove previous build artifacts:

```bash
rm -rf \
    build/ \
    dist/ \
    *.egg-info
```

---

## Build Wheel

FlashAttention compilation can consume a large amount of RAM.

For a build machine with approximately 100 GB RAM:

```bash
MAX_JOBS=8 python -m build --wheel --no-isolation
```

If memory usage becomes excessive, reduce parallelism:

```bash
MAX_JOBS=3 python -m build --wheel --no-isolation
```

The resulting wheel is created in:

```text
/workspace/flash-attention/dist/
```

Example for Python 3.12:

```text
flash_attn-2.x.x-cp312-cp312-linux_x86_64.whl
```

The exact version and Python ABI tag depend on the checked-out FlashAttention revision and Python version.

---

## Inspect Wheel

```bash
ls -lh dist/
```

List the compiled shared objects:

```bash
unzip -l dist/flash_attn-*.whl | grep '\.so'
```

FlashAttention normally contains its CUDA extension in a file similar to:

```text
flash_attn_2_cuda.cpython-312-x86_64-linux-gnu.so
```

---

## Extract Wheel for CUDA Verification

```bash
rm -rf /tmp/flash-wheel

unzip -q \
    dist/flash_attn-*.whl \
    -d /tmp/flash-wheel
```

Locate the compiled CUDA extensions:

```bash
find /tmp/flash-wheel -type f -name '*.so' -print
```

---

## Verify Native CUDA Architectures

Check all compiled extensions for the requested architectures:

```bash
for so in $(find /tmp/flash-wheel -type f -name '*.so'); do
    echo
    echo "===== $(basename "$so") ====="

    for arch in sm_86 sm_89 sm_120; do
        if cuobjdump --dump-sass \
            --gpu-architecture "$arch" \
            "$so" \
            >/dev/null 2>&1; then
            echo "  ✅ $arch"
        else
            echo "  ❌ $arch"
        fi
    done
done
```

The intended result is:

```text
===== flash_attn_2_cuda.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120
```

This is the definitive verification that native CUDA code for all three architectures is present in the wheel.

---

## Runtime Requirements

Because FlashAttention has already been compiled into the wheel, the final ComfyUI runtime does **not** require:

```text
nvcc
CUDA development toolkit
CUDA headers
build-essential
ninja
```

The runtime still requires:

- Compatible NVIDIA driver
- Compatible PyTorch installation
- Compatible CUDA runtime
- Matching Python ABI
- x86_64 Linux environment

For this build, keep the runtime as close as possible to:

```text
Ubuntu 24.04
Python 3.12
PyTorch 2.10.x
PyTorch CUDA 12.8 / cu128
x86_64
```

---

## Install in ComfyUI Runtime

```bash
pip install \
    /workspace/flash-attention/dist/flash_attn-2.*.whl
```

---

## Import Check

```bash
python - <<'PY'
import torch
import flash_attn

print("PyTorch:", torch.__version__)
print("PyTorch CUDA:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name())
    print("Compute capability:", torch.cuda.get_device_capability())

print("FlashAttention:", flash_attn.__version__)
print("Location:", flash_attn.__file__)
PY
```

---

## Functional Test

```bash
python - <<'PY'
import torch
from flash_attn import flash_attn_func

q = torch.randn(
    2,
    128,
    4,
    64,
    device="cuda",
    dtype=torch.float16,
)

k = torch.randn_like(q)
v = torch.randn_like(q)

output = flash_attn_func(
    q,
    k,
    v,
    causal=False,
)

torch.cuda.synchronize()

print("GPU:", torch.cuda.get_device_name())
print("Compute capability:", torch.cuda.get_device_capability())
print("Output:", output.shape)
print("dtype:", output.dtype)
PY
```

Expected:

```text
Output: torch.Size([2, 128, 4, 64])
dtype: torch.float16
```

Note that FlashAttention uses the tensor layout:

```text
batch × sequence × heads × head_dim
```

Therefore this test returns:

```text
[2, 128, 4, 64]
```

rather than SageAttention's HND test shape:

```text
[2, 4, 128, 64]
```

---

## ComfyUI Runtime Validation

The same wheel is intended to contain native CUDA targets for:

```text
RTX 3090 / A40 / RTX A6000  -> SM86  -> Ampere
RTX 4090 / L40S             -> SM89  -> Ada Lovelace
RTX 5090                     -> SM120 -> Blackwell
```

Test the installed wheel on each target GPU class where possible.

---

# Short Build Version

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"
export CUDAARCHS="86;89;120"

export MAX_JOBS=8
export USE_NINJA=1

cd /workspace

git clone \
    https://github.com/Dao-AILab/flash-attention.git \
    --recursive

cd flash-attention

rm -rf build/ dist/ *.egg-info

python -m pip install --upgrade pip
pip install -U build ninja packaging wheel setuptools

echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"
echo "CUDAARCHS=${CUDAARCHS}"

python -m build --wheel --no-isolation
```

---

# Short Verification Version

```bash
rm -rf /tmp/flash-wheel

unzip -q \
    dist/flash_attn-*.whl \
    -d /tmp/flash-wheel

for so in $(find /tmp/flash-wheel -type f -name '*.so'); do
    echo
    echo "===== $(basename "$so") ====="

    for arch in sm_86 sm_89 sm_120; do
        if cuobjdump --dump-sass \
            --gpu-architecture "$arch" \
            "$so" \
            >/dev/null 2>&1; then
            echo "  ✅ $arch"
        else
            echo "  ❌ $arch"
        fi
    done
done
```

Expected:

```text
===== flash_attn_2_cuda.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120
```

---

# Result

One FlashAttention 2 wheel intended to contain native CUDA support for:

```text
SM86  -> Ampere
SM89  -> Ada Lovelace
SM120 -> Blackwell
```

Architecture configuration:

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"
export CUDAARCHS="86;89;120"
```

After compilation, verify the actual native architectures with `cuobjdump` before deploying the wheel to the ComfyUI runtime.