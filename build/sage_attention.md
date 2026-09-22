# Build SageAttention 2++ Wheel — Ampere + Ada + Blackwell

## Target Environment

- Ubuntu 24.04
- PyTorch 2.12
- CUDA 13.0
- NVIDIA Ampere — SM86
- NVIDIA Ada Lovelace — SM89
- NVIDIA Blackwell — SM120 / SM120a
- Build environment contains `nvcc`
- Runtime environment does **not** require `nvcc`
- Target: ComfyUI runtime
- Architecture: x86_64

## Official

- [SageAttention GitHub](https://github.com/thu-ml/SageAttention)

## Supported GPU Architectures

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere | 8.6 | `sm_86` | RTX 3090, RTX A5000, RTX A6000, A40 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40 |
| Blackwell | 12.0 | `sm_120a` | RTX 5090, RTX 5080, RTX 5070 Ti |

SageAttention's `setup.py` translates:

```text
8.6  -> compute_86   -> sm_86
8.9  -> compute_89   -> sm_89
12.0 -> compute_120a -> sm_120a
```

CUDA 13.0 or newer is required to compile the Blackwell 12.0 target.

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

Explicitly compile native CUDA kernels for Ampere, Ada Lovelace and Blackwell:

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"

export MAX_JOBS=16
export EXT_PARALLEL=4

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

Do **not** rely on automatic GPU detection when building a wheel intended for multiple GPU generations.

Without `TORCH_CUDA_ARCH_LIST`, SageAttention detects the GPU or GPUs installed in the build machine. Building on a machine containing only an RTX 5090 would therefore select only compute capability `12.0`.

### NVCC Threads

The current SageAttention `setup.py` already contains:

```text
--threads=8
```

in `NVCC_FLAGS`.

Therefore, this is unnecessary:

```bash
export NVCC_APPEND_FLAGS="--threads 8"
```

---

## Dependencies

```bash
python -m pip install --upgrade pip

pip install \
    "packaging<24,>=21" \
    "setuptools<75,>=62" \
    "wheel<0.44,>=0.38" \
    "build>=1.2" \
    ninja
```

---

## Clone

```bash
cd /workspace

git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
```

Record the exact SageAttention revision:

```bash
git rev-parse HEAD
```

---

## Clean

Remove previous build artifacts:

```bash
rm -rf \
    build/ \
    dist/ \
    *.egg-info \
    sageattention/*.so
```

---

## Build Wheel

Confirm the architecture configuration immediately before building:

```bash
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"
```

Expected:

```text
TORCH_CUDA_ARCH_LIST=8.6;8.9;12.0
```

Build:

```bash
python -m build --wheel --no-isolation
```

During configuration, SageAttention should report all three compute capabilities:

```text
Target compute capabilities: {'8.6', '8.9', '12.0'}
```

The order may differ because Python stores these values in a set.

The NVCC compile commands should contain:

```text
-gencode arch=compute_86,code=sm_86
-gencode arch=compute_89,code=sm_89
-gencode arch=compute_120a,code=sm_120a
```

The resulting wheel is created in:

```text
/workspace/SageAttention/dist/
```

Example for Python 3.12:

```text
sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
```

The exact Python ABI tag depends on the Python version used for compilation.

---

## Inspect Wheel

```bash
ls -lh dist/
```

Check that the compiled CUDA extensions are included:

```bash
unzip -l dist/sageattention-*.whl | grep '\.so'
```

A Python 3.12 build can contain:

```text
sageattention/_fused.cpython-312-x86_64-linux-gnu.so
sageattention/_qattn_sm80.cpython-312-x86_64-linux-gnu.so
sageattention/_qattn_sm89.cpython-312-x86_64-linux-gnu.so
```

### Important

The extension filenames do **not** indicate all GPU architectures embedded in the binary.

For example:

```text
_qattn_sm89.cpython-312-x86_64-linux-gnu.so
```

can contain native CUDA code for:

```text
sm_86
sm_89
sm_120a
```

The actual embedded architectures should therefore be verified with `cuobjdump`.

---

## Extract Wheel for CUDA Verification

```bash
rm -rf /tmp/sage-wheel

unzip -q \
    dist/sageattention-*.whl \
    -d /tmp/sage-wheel
```

---

## Verify Native CUDA Architectures

Check every compiled SageAttention extension against all three target architectures:

```bash
for so in /tmp/sage-wheel/sageattention/*.so; do
    echo
    echo "===== $(basename "$so") ====="

    for arch in sm_86 sm_89 sm_120a; do
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
===== _fused.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120a

===== _qattn_sm80.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120a

===== _qattn_sm89.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120a
```

This confirms that the wheel contains native CUDA code for Ampere, Ada Lovelace and Blackwell.

---

## Runtime Requirements

Because the CUDA extensions are already compiled into the wheel, the final ComfyUI runtime environment does **not** require:

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
- Compatible CUDA runtime used by PyTorch
- Matching Python ABI
- x86_64 Linux environment

For this build, the runtime should match the build environment as closely as possible:

```text
Ubuntu 24.04
Python 3.12
PyTorch 2.12
PyTorch CUDA 1.3 / cu13
x86_64
```

A wheel named:

```text
sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
```

requires CPython 3.12.

---

## Install in ComfyUI Runtime

```bash
pip install /workspace/SageAttention/dist/sageattention-2.2.0-*.whl
```

A CUDA compiler is not required in the runtime container.

---

## Import Check

```bash
python - <<'PY'
import torch
import sageattention

print("PyTorch:", torch.__version__)
print("PyTorch CUDA:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name())
    print("Compute capability:", torch.cuda.get_device_capability())

PY
```

---

## Functional Test

```bash
python /workspace/build/test_sage.py
```

Expected:

```text
Output: torch.Size([2, 4, 128, 64])
```

---

# Short Build Version

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"

export MAX_JOBS=16
export EXT_PARALLEL=4
export CMAKE_BUILD_PARALLEL_LEVEL=16
export USE_NINJA=1

cd /workspace

git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention

rm -rf build/ dist/ *.egg-info sageattention/*.so

python -m pip install --upgrade pip
pip install -U build ninja packaging wheel setuptools

echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"

python -m build --wheel --no-isolation
```

---

# Short Verification Version

Extract the generated wheel:

```bash
rm -rf /tmp/sage-wheel

unzip -q \
    dist/sageattention-*.whl \
    -d /tmp/sage-wheel
```

Verify all three native CUDA architectures:

```bash
for so in /tmp/sage-wheel/sageattention/*.so; do
    echo
    echo "===== $(basename "$so") ====="

    for arch in sm_86 sm_89 sm_120a; do
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
===== _fused.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120a

===== _qattn_sm80.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120a

===== _qattn_sm89.cpython-312-x86_64-linux-gnu.so =====
  ✅ sm_86
  ✅ sm_89
  ✅ sm_120a
```

---

# Result

One SageAttention 2.2.0 wheel containing native CUDA support for:

```text
SM86   -> Ampere
SM89   -> Ada Lovelace
SM120a -> Blackwell
```

Recommended architecture configuration:

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0"
```

This produces native SASS for all three requested architectures.

No `+PTX` target is required because all three target architectures are compiled explicitly into the wheel.