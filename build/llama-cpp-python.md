# Build llama-cpp-python CUDA Wheel — Ampere to Blackwell

## Verified Versions

Last verified: **2026-09-22**

- `llama-cpp-python`: **0.3.35**
- Vendored `llama.cpp` revision: `e3546c794`
- CUDA Toolkit: **13.0**
- Target: ComfyUI runtime
- Platform: Ubuntu 24.04, x86_64

Version 0.3.34 is the latest PyPI release at the verification date. Pinning the
version makes the wheel reproducible; check PyPI before deliberately updating it.

## Official Sources

- [llama-cpp-python GitHub](https://github.com/abetlen/llama-cpp-python)
- [llama-cpp-python on PyPI](https://pypi.org/project/llama-cpp-python/)
- [llama.cpp CUDA CMake configuration](https://github.com/ggml-org/llama.cpp/blob/master/ggml/src/ggml-cuda/CMakeLists.txt)
- [NVIDIA compute capability table](https://developer.nvidia.com/cuda/gpus)

## Supported GPU Architectures

This configuration builds one wheel with native CUDA code for the principal
Ampere, Ada, Hopper and Blackwell targets available with CUDA 12.8:

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere data center | 8.0 | `sm_80` | A100, A30 |
| Ampere | 8.6 | `sm_86` | RTX 3090, RTX A6000, A40, A10 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40, L40S |
| Hopper | 9.0 | `sm_90` | H100, H200, GH200 |
| Blackwell data center | 10.0 | `sm_100a` | B100, B200, GB200 |
| Blackwell workstation/consumer | 12.0 | `sm_120a` | RTX 5090, RTX 5080, RTX 5070 Ti |

The `a` suffix is intentional. Current `llama.cpp` automatically rewrites a
plain `120` target to `120a`, because its Blackwell FP4 kernels require
architecture-specific instructions. The explicit `-real` suffix below asks
CMake for native SASS only and avoids adding redundant PTX for every target.

CUDA 12.8 or newer is required for native Blackwell compilation. GPUs with a
different compute capability need their own target or a suitable PTX target.

---

## Verify Build Environment

```bash
python --version
python -m pip --version
cmake --version
nvcc --version

nvidia-smi --query-gpu=name,compute_cap --format=csv
```

The build image must contain `nvcc`, a supported C/C++ compiler, CMake and the
CUDA development libraries. A GPU does not have to be attached because the
architecture list is set explicitly.

---

## Configuration

```bash
export LLAMA_CPP_PYTHON_VERSION="0.3.35"
export CUDAARCHS="80-real;86-real;89-real;90-real;100a-real;120a-real"

export CMAKE_ARGS="-DGGML_CUDA=ON -DGGML_NATIVE=OFF -DCMAKE_CUDA_ARCHITECTURES=${CUDAARCHS}"
export CMAKE_BUILD_PARALLEL_LEVEL=10
export CMAKE_GENERATOR=Ninja
```

Verify immediately before building:

```bash
echo "LLAMA_CPP_PYTHON_VERSION=${LLAMA_CPP_PYTHON_VERSION}"
echo "CUDAARCHS=${CUDAARCHS}"
echo "CMAKE_ARGS=${CMAKE_ARGS}"
```

Expected architecture configuration:

```text
80-real;86-real;89-real;90-real;100a-real;120a-real
```

Do not rely on automatic GPU detection for a wheel intended for several GPU
generations. `GGML_NATIVE=OFF` also avoids tuning the CPU side of the wheel for
only the build machine.

---

## Dependencies

```bash
python -m pip install --upgrade pip

python -m pip install --upgrade \
    build \
    cmake \
    ninja \
    "scikit-build-core[pyproject]>=0.9.2" \
    wheel
```

`llama-cpp-python` now uses `scikit-build-core`. `FORCE_CMAKE=1` is not needed
when `pip wheel` is forced to build from the source distribution.

---

## Clean

```bash
cd /workspace
rm -rf wheelhouse /tmp/llama-cpp-wheel
mkdir -p wheelhouse
```

---

## Build Wheel

```bash
python -m pip wheel \
    --no-cache-dir \
    --no-deps \
    --no-build-isolation \
    --no-binary llama-cpp-python \
    --wheel-dir wheelhouse \
    "llama-cpp-python==${LLAMA_CPP_PYTHON_VERSION}"
```

During CMake configuration, confirm this line is present:

```text
Using CMAKE_CUDA_ARCHITECTURES=80-real;86-real;89-real;90-real;100a-real;120a-real
```

The resulting wheel is created in:

```text
/workspace/wheelhouse/
```

The exact platform tag is determined by the build environment. Recent releases
use Python's stable `py3` wheel tag while still containing native Linux shared
libraries.

---

## Inspect Wheel

```bash
ls -lh wheelhouse/
unzip -l wheelhouse/llama_cpp_python-*.whl | grep -E '(libggml|libllama).*\.so'
```

Extract it for CUDA inspection:

```bash
unzip -q \
    wheelhouse/llama_cpp_python-*.whl \
    -d /tmp/llama-cpp-wheel

CUDA_SO=$(find /tmp/llama-cpp-wheel -type f -name 'libggml-cuda.so*' -print -quit)
test -n "${CUDA_SO}"
echo "${CUDA_SO}"
```

---

## Verify Native CUDA Architectures

List the CUDA images embedded in `libggml-cuda`:

```bash
cuobjdump --list-elf "${CUDA_SO}" \
    | grep -E 'sm_(80|86|89|90|100a|120a)'
```

Require every configured architecture:

```bash
for arch in sm_80 sm_86 sm_89 sm_90 sm_100a sm_120a; do
    if cuobjdump --list-elf "${CUDA_SO}" | grep -q "${arch}"; then
        echo "  OK ${arch}"
    else
        echo "  MISSING ${arch}"
        exit 1
    fi
done
```

Expected:

```text
OK sm_80
OK sm_86
OK sm_89
OK sm_90
OK sm_100a
OK sm_120a
```

This binary inspection is stronger evidence than the filename: a single
`libggml-cuda.so` can contain all six native targets.

---

## Install in the ComfyUI Runtime

```bash
python -m pip install \
    --force-reinstall \
    wheelhouse/llama_cpp_python-*.whl
```

The runtime does not require `nvcc`, CMake, Ninja, CUDA headers or a C/C++
compiler. Allow `pip` to install the Python runtime dependencies (`diskcache`,
`jinja2`, `numpy` and `typing-extensions`). The runtime also requires a
compatible NVIDIA driver and the CUDA runtime libraries used by the wheel.

---

## Import and Backend Check

```bash
python - <<'PY'
import llama_cpp

info = llama_cpp.llama_cpp.llama_print_system_info().decode()

print("llama-cpp-python:", llama_cpp.__version__)
print(info)

assert llama_cpp.__version__ == "0.3.35"
assert "CUDA" in info, "llama-cpp-python was not built with the CUDA backend"
PY
```

---

## Functional GPU Test

Download the small GGUF model with the current `hf` CLI:

```bash
hf download \
    TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF \
    tinyllama-1.1b-chat-v1.0.Q8_0.gguf \
    --local-dir /workspace
```

Run the repository test with CUDA logging enabled:

```bash
export LLAMA_LOG_LEVEL=info
python /build/test_llama-cpp.py
```

The log must report that the CUDA backend loaded and that model layers were
offloaded to the GPU. Run this test on each GPU family for which the wheel is
published; binary inspection proves that code is present, while a runtime test
also validates the driver and CUDA libraries.

# Short Build Version

```bash
export LLAMA_CPP_PYTHON_VERSION="0.3.35"
export CUDAARCHS="80-real;86-real;89-real;90-real;100a-real;120a-real"
export CMAKE_ARGS="-DGGML_CUDA=ON -DGGML_NATIVE=OFF -DCMAKE_CUDA_ARCHITECTURES=${CUDAARCHS}"
export CMAKE_BUILD_PARALLEL_LEVEL=16
export CMAKE_GENERATOR=Ninja

cd /workspace
rm -rf wheelhouse
mkdir -p wheelhouse

python -m pip install -U \
    build cmake ninja "scikit-build-core[pyproject]>=0.9.2" wheel

python -m pip wheel \
    --no-cache-dir \
    --no-deps \
    --no-build-isolation \
    --no-binary llama-cpp-python \
    --wheel-dir wheelhouse \
    "llama-cpp-python==${LLAMA_CPP_PYTHON_VERSION}"
```

---

# Short Verification Version

```bash
rm -rf /tmp/llama-cpp-wheel
unzip -q wheelhouse/llama_cpp_python-*.whl -d /tmp/llama-cpp-wheel

CUDA_SO=$(find /tmp/llama-cpp-wheel -type f -name 'libggml-cuda.so*' -print -quit)
test -n "${CUDA_SO}"

for arch in sm_80 sm_86 sm_89 sm_90 sm_100a sm_120a; do
    cuobjdump --list-elf "${CUDA_SO}" | grep -q "${arch}" \
        && echo "OK ${arch}" \
        || exit 1
done
```

---

# Result

One pinned `llama-cpp-python` 0.3.34 wheel containing the CUDA backend and
native code for:

```text
SM80   -> Ampere data center
SM86   -> Ampere
SM89   -> Ada Lovelace
SM90   -> Hopper
SM100a -> Blackwell data center
SM120a -> Blackwell workstation/consumer
```
