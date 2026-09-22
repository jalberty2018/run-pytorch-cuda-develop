# Build FlashAttention 2 Wheel — Ampere + Ada + Blackwell

## Target Environment

- Ubuntu 24.04
- Python 3.12
- PyTorch 2.12.1
- CUDA 13.0
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

| Architecture | Compute Capability | Embedded CUDA Target | Examples |
|---|---:|---:|---|
| Ampere | 8.6 | `sm_80` (binary compatible) | RTX 3090, RTX A5000, RTX A6000, A40 |
| Ada Lovelace | 8.9 | `sm_80` (binary compatible) | RTX 4090, RTX 6000 Ada, L40, L40S |
| Blackwell | 12.0 | `sm_120` | RTX 5090, RTX PRO 6000 Blackwell |

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
export FLASH_ATTN_CUDA_ARCHS="80;120"
export FLASH_ATTENTION_FORCE_BUILD=TRUE
export USE_NINJA=1
export BUILD_TARGET=cuda
```

Verify:

```bash
echo "FLASH_ATTN_CUDA_ARCHS=${FLASH_ATTN_CUDA_ARCHS}"
echo "FLASH_ATTENTION_FORCE_BUILD=${FLASH_ATTENTION_FORCE_BUILD}"
```

Expected:

```text
FLASH_ATTN_CUDA_ARCHS=80;120
FLASH_ATTENTION_FORCE_BUILD=TRUE
```

FlashAttention's `setup.py` uses `FLASH_ATTN_CUDA_ARCHS` to select its CUDA
kernels; `TORCH_CUDA_ARCH_LIST` and `CUDAARCHS` do not control this selection.
SM80 cubins are binary compatible with the SM86 Ampere and SM89 Ada GPUs
listed above. SM120 covers the listed Blackwell GPUs. Separate SM86/SM89
cubins are not expected from this configuration.

`FLASH_ATTENTION_FORCE_BUILD=TRUE` forces local compilation instead of using
a prebuilt wheel. When changing these settings, run the Clean step before
rebuilding, then extract the new wheel again before verification.

See [FlashAttention setup.py](https://github.com/Dao-AILab/flash-attention/blob/main/setup.py)
and [NVIDIA Ada compatibility](https://docs.nvidia.com/cuda/ada-compatibility-guide/).

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

Use a shallow clone of the main repository and initialize only NVIDIA CUTLASS.
The AMD/ROCm submodules (`csrc/composable_kernel` and `third_party/aiter`) are
not needed for this CUDA build. `BUILD_TARGET=cuda` also selects the CUDA path
in `setup.py`, which initializes CUTLASS only.

```bash
cd /workspace

git clone \
    --depth 1 \
    --single-branch \
    https://github.com/Dao-AILab/flash-attention.git

cd flash-attention
git submodule update --init --depth 1 -- csrc/cutlass
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

For a build machine with approximately 120 GB RAM:

```bash
MAX_JOBS=8 python -m build --wheel --no-isolation
```

For a build machine with approximately 85 GB RAM:

```bash
MAX_JOBS=4 python -m build --wheel --no-isolation
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

Use Bash to list embedded cubins once per FlashAttention CUDA extension.
This avoids the expensive kernel disassembly performed by `--dump-sass`.
The check matches actual SM80 and SM120 cubin entries, reports missing
architectures, and returns a nonzero status on failure. Tool errors remain visible.

```bash
(
    mapfile -d '' -t extensions < <(find /tmp/flash-wheel -type f -name 'flash_attn_2_cuda*.so' -print0)
    if (( ${#extensions[@]} == 0 )); then
        echo "ERROR: FlashAttention CUDA extension not found"
        exit 1
    fi

    status=0
    for so in "${extensions[@]}"; do
        echo "===== $(basename "$so") ====="
        if ! elf_list=$(cuobjdump --list-elf "$so"); then
            echo "ERROR: cuobjdump failed"
            exit 1
        fi
        echo "Embedded architectures:"
        printf '%s\n' "$elf_list" | grep -oE 'sm_[0-9]+[af]?' | sort -u

        for arch in sm_80 sm_120; do
            if grep -Eq "[.]${arch}[.]cubin([[:space:]]|$)" <<< "$elf_list"; then
                echo "  OK $arch"
            else
                echo "  MISSING $arch"
                status=1
            fi
        done
    done
    exit "$status"
)
```

The intended result is:

```text
===== flash_attn_2_cuda.cpython-312-x86_64-linux-gnu.so =====
Embedded architectures:
sm_120
sm_80
  OK sm_80
  OK sm_120
```

This confirms embedded SM80 and SM120 code, not successful GPU execution.
Additional architectures in an older wheel are allowed. Run the Functional
Test on each target GPU family to validate runtime compatibility.

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
PyTorch 2.11.1
PyTorch CUDA 13.0 / cu130
x86_64
```

---

## Install Runtime

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

## Runtime Validation

The same wheel is intended to support these GPUs using the embedded targets:

```text
RTX 3090 / A40 / RTX A6000        -> SM86 GPU  -> SM80 cubins
RTX 4090 / L40S / RTX 6000 Ada    -> SM89 GPU  -> SM80 cubins
RTX 5090 / RTX PRO 6000 Blackwell -> SM120 GPU -> SM120 cubins
```

Test the installed wheel on each target GPU class where possible.

---

# Short Build Version

```bash
export FLASH_ATTN_CUDA_ARCHS="80;120"
export FLASH_ATTENTION_FORCE_BUILD=TRUE

export USE_NINJA=1
export BUILD_TARGET=cuda

cd /workspace

git clone \
    --depth 1 \
    --single-branch \
    https://github.com/Dao-AILab/flash-attention.git

cd flash-attention
git submodule update --init --depth 1 -- csrc/cutlass

rm -rf build/ dist/ *.egg-info

python -m pip install --upgrade pip
pip install -U build ninja packaging wheel setuptools

echo "FLASH_ATTN_CUDA_ARCHS=${FLASH_ATTN_CUDA_ARCHS}"
echo "FLASH_ATTENTION_FORCE_BUILD=${FLASH_ATTENTION_FORCE_BUILD}"

python -m build --wheel --no-isolation
```

---

# Short Verification Version

```bash
rm -rf /tmp/flash-wheel

unzip -q \
    dist/flash_attn-*.whl \
    -d /tmp/flash-wheel

(
    mapfile -d '' -t extensions < <(find /tmp/flash-wheel -type f -name 'flash_attn_2_cuda*.so' -print0)
    if (( ${#extensions[@]} == 0 )); then
        echo "ERROR: FlashAttention CUDA extension not found"
        exit 1
    fi

    status=0
    for so in "${extensions[@]}"; do
        echo "===== $(basename "$so") ====="
        if ! elf_list=$(cuobjdump --list-elf "$so"); then
            echo "ERROR: cuobjdump failed"
            exit 1
        fi
        echo "Embedded architectures:"
        printf '%s\n' "$elf_list" | grep -oE 'sm_[0-9]+[af]?' | sort -u

        for arch in sm_80 sm_120; do
            if grep -Eq "[.]${arch}[.]cubin([[:space:]]|$)" <<< "$elf_list"; then
                echo "  OK $arch"
            else
                echo "  MISSING $arch"
                status=1
            fi
        done
    done
    exit "$status"
)
```

Expected:

```text
===== flash_attn_2_cuda.cpython-312-x86_64-linux-gnu.so =====
Embedded architectures:
sm_120
sm_80
  OK sm_80
  OK sm_120
```

---

# Result

One FlashAttention 2 wheel with embedded CUDA code for:

```text
SM80  -> Ampere SM86 and Ada SM89 through binary compatibility
SM120 -> Blackwell SM120
```

Architecture configuration:

```bash
export FLASH_ATTN_CUDA_ARCHS="80;120"
export FLASH_ATTENTION_FORCE_BUILD=TRUE
```

After compilation, verify the actual native architectures with `cuobjdump` before deploying the wheel to the ComfyUI runtime.
