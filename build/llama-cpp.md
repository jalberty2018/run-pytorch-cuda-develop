# Build llama.cpp with CUDA — Ampere to Blackwell

## Verified Versions

Last checked: **2026-08-21**

- `llama.cpp`: **b10218** (`de69995`)
- CUDA Toolkit: **12.8.1**
- Build image: `run-pytorch-cuda-develop`
- Platform: Ubuntu 24.04, x86_64

The release tag is pinned so the build can be reproduced. Update
`LLAMA_CPP_TAG` deliberately after checking the upstream release notes and
repeating the binary and runtime verification below.

Unlike [`llama-cpp-python.md`](llama-cpp-python.md), this guide builds the
native `llama.cpp` command-line tools and shared libraries. It does not create
or install a Python wheel.

## Official Sources

- [llama.cpp GitHub](https://github.com/ggml-org/llama.cpp)
- [Official build guide](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
- [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases)
- [CUDA CMake configuration](https://github.com/ggml-org/llama.cpp/blob/master/ggml/src/ggml-cuda/CMakeLists.txt)
- [NVIDIA compute capability table](https://developer.nvidia.com/cuda/gpus)

## Supported GPU Architectures

This configuration builds one set of binaries with native CUDA code for the
principal Ampere, Ada, Hopper and Blackwell targets supported by CUDA 12.8:

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere data center | 8.0 | `sm_80` | A100, A30 |
| Ampere | 8.6 | `sm_86` | RTX 3090, RTX A6000, A40, A10 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40, L40S |
| Hopper | 9.0 | `sm_90` | H100, H200, GH200 |
| Blackwell data center | 10.0 | `sm_100a` | B100, B200, GB200 |
| Blackwell workstation/consumer | 12.0 | `sm_120a` | RTX 5090, RTX 5080, RTX 5070 Ti |

The `a` suffix is intentional for architecture-specific Blackwell code. The
`-real` suffix asks CMake to emit native SASS only, rather than both SASS and
PTX for every target. CUDA 12.8 or newer is required for native Blackwell
compilation.

GPUs with another compute capability require an additional target or a
suitable `-virtual` PTX target. Removing unused targets reduces build time and
artifact size.

---

## Verify the Build Environment

```bash
git --version
cmake --version
ninja --version
nvcc --version
g++ --version

nvidia-smi --query-gpu=name,compute_cap --format=csv
```

The image must contain Git, CMake, Ninja, a supported C/C++ compiler, `nvcc`
and the CUDA development libraries. A GPU is not required during compilation
because the architecture list is explicit.

If CMake or Ninja is missing, install them in the build image:

```bash
python -m pip install --upgrade cmake ninja
```

---

## Configuration

```bash
export LLAMA_CPP_TAG="b10218"
export CUDAARCHS="80-real;86-real;89-real;90-real;100a-real;120a-real"

export LLAMA_CPP_SOURCE="/workspace/llama.cpp"
export LLAMA_CPP_BUILD="/workspace/llama.cpp/build-cuda"
export LLAMA_CPP_PREFIX="/workspace/llama-cpp-dist"
export CMAKE_BUILD_PARALLEL_LEVEL=16
```

Verify the values before building:

```bash
echo "LLAMA_CPP_TAG=${LLAMA_CPP_TAG}"
echo "CUDAARCHS=${CUDAARCHS}"
echo "LLAMA_CPP_SOURCE=${LLAMA_CPP_SOURCE}"
echo "LLAMA_CPP_BUILD=${LLAMA_CPP_BUILD}"
echo "LLAMA_CPP_PREFIX=${LLAMA_CPP_PREFIX}"
```

Expected architecture configuration:

```text
80-real;86-real;89-real;90-real;100a-real;120a-real
```

`GGML_NATIVE=OFF` in the next section prevents the CPU backend from being
tuned only for the build machine and avoids automatic GPU detection.

---

## Get the Pinned Source

Start from a clean workspace path:

```bash
cd /workspace
rm -rf /workspace/llama.cpp /workspace/llama-cpp-dist

git clone \
    --branch "${LLAMA_CPP_TAG}" \
    --depth 1 \
    https://github.com/ggml-org/llama.cpp.git \
    "${LLAMA_CPP_SOURCE}"

git -C "${LLAMA_CPP_SOURCE}" rev-parse --short HEAD
git -C "${LLAMA_CPP_SOURCE}" describe --tags --exact-match
```

Expected:

```text
de69995
b10218
```

---

## Configure and Build

```bash
cmake \
    -S "${LLAMA_CPP_SOURCE}" \
    -B "${LLAMA_CPP_BUILD}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES="${CUDAARCHS}" \
    -DCMAKE_INSTALL_PREFIX="${LLAMA_CPP_PREFIX}" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH='$ORIGIN/../lib;$ORIGIN' \
    -DGGML_CUDA=ON \
    -DGGML_NATIVE=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON

cmake \
    --build "${LLAMA_CPP_BUILD}" \
    --config Release \
    --parallel "${CMAKE_BUILD_PARALLEL_LEVEL}"
```

During CMake configuration, confirm this line is present:

```text
Using CMAKE_CUDA_ARCHITECTURES=80-real;86-real;89-real;90-real;100a-real;120a-real
```

The main build products are under:

```text
/workspace/llama.cpp/build-cuda/bin/
```

---

## Install into a Portable Prefix

```bash
cmake \
    --install "${LLAMA_CPP_BUILD}" \
    --config Release

find "${LLAMA_CPP_PREFIX}" -maxdepth 2 -type f \
    | sort
```

Make the installed tools and shared libraries available in the current shell:

```bash
export PATH="${LLAMA_CPP_PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${LLAMA_CPP_PREFIX}/lib:${LD_LIBRARY_PATH:-}"
```

Check the installed binaries and dynamic libraries:

```bash
llama-cli --version
llama-server --version
llama-cli --list-devices

ldd "${LLAMA_CPP_PREFIX}/bin/llama-cli" \
    | grep -E '(ggml|llama|cuda|cublas)'
```

`llama-cli --list-devices` must list a CUDA device when run on a host with a
compatible NVIDIA driver and GPU.

---

## Verify Native CUDA Architectures

Locate the installed CUDA backend:

```bash
CUDA_SO=$(find "${LLAMA_CPP_PREFIX}" \
    -type f -name 'libggml-cuda.so*' -print -quit)

test -n "${CUDA_SO}"
echo "${CUDA_SO}"
```

Require every configured architecture in the shared library:

```bash
for arch in sm_80 sm_86 sm_89 sm_90 sm_100a sm_120a; do
    if cuobjdump --list-elf "${CUDA_SO}" | grep -q "${arch}"; then
        echo "OK ${arch}"
    else
        echo "MISSING ${arch}"
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

This inspects the actual CUDA images in `libggml-cuda`, which is stronger
evidence than the CMake output or artifact filename alone.

---

## Functional GPU Test

Download a small public GGUF model with the current `hf` CLI:

```bash
mkdir -p /workspace/models

hf download \
    TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF \
    tinyllama-1.1b-chat-v1.0.Q8_0.gguf \
    --local-dir /workspace/models
```

Run inference with all model layers offloaded to the GPU:

```bash
export LLAMA_LOG_LEVEL=info

llama-cli \
    --model /workspace/models/tinyllama-1.1b-chat-v1.0.Q8_0.gguf \
    --n-gpu-layers 99 \
    --ctx-size 2048 \
    --predict 64 \
    --prompt "Hello, I am PyTorch. Who are you?"
```

The startup log must report that the CUDA backend loaded, identify the NVIDIA
device and show model layers being offloaded. Repeat the runtime test on each
GPU family for which the artifact is published; binary inspection proves code
is embedded, while inference also validates the driver and runtime libraries.

An optional benchmark provides a second functional check:

```bash
llama-bench \
    --model /workspace/models/tinyllama-1.1b-chat-v1.0.Q8_0.gguf \
    --n-gpu-layers 99 \
    --prompt 512 \
    --generation 128
```

---

## Optional Multimodal Vision-Language Test

This additional test validates `llama-mtmd-cli`, the CUDA backend and the
multimodal projector with an image-to-text prompt. It uses a Qwen3.8 27B
language-model quantization and the matching base-model vision projector.
The language model requires about 16.8 GB of storage and the F16 projector
about 928 MB.

Download both GGUF files:

```bash
mkdir -p /workspace/models

hf download \
    theresa00l/Qwen3.8-27B-Uncensored-FP8-Q4_K_M-GGUF \
    qwen3.8-27b-uncensored-fp8-q4_k_m.gguf \
    --local-dir /workspace/models

hf download \
    unsloth/Qwen3.8-27B-GGUF \
    mmproj-F16.gguf \
    --local-dir /workspace/models
```

Download the public test image used by the model card:

```bash
curl -L \
    https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG \
    -o /workspace/candy.jpg
```

Run the vision-language test:

```bash
llama-mtmd-cli \
    --model /workspace/models/qwen3.8-27b-uncensored-fp8-q4_k_m.gguf \
    --mmproj /workspace/models/mmproj-F16.gguf \
    --image /workspace/candy.jpg \
    --prompt "/no_think Beschrijf deze afbeelding kort in maximaal drie zinnen Nederlands." \
    --jinja \
    --image-min-tokens 1024 \
    --n-gpu-layers 99 \
    --ctx-size 8192 \
    --predict 2048 \
    --temp 0.2
```

`--predict 2048` is an upper limit; generation stops earlier when the model
emits its end token. In the verified run, the model identified an open hand,
five colored objects and turtle-like symbols, then returned a complete Dutch
answer.

The b10218 experimental multimodal CLI can emit warnings about unused
`blk.64` tensors and non-consecutive token positions. These warnings did not
prevent image encoding or a correct response in the verified run. The
`blk.64` tensors belong to the model's extra next-token-prediction component
and are ignored by this inference path. The CLI also does not accept the
`--reasoning` option in this release; `/no_think` is included in the prompt to
request a concise response. The active Jinja template may still produce a
short reasoning section before the final answer.

Treat a failed image encode, a projector/model incompatibility error, a CUDA
backend load failure or an absent final description as a failed test. Because
the projector is architecture-specific, use it only with a Qwen3.8 27B model
that retains the base model's vision architecture.

---

## Package the Native Build

```bash
tar \
    -C "${LLAMA_CPP_PREFIX}" \
    -czf "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz" \
    .

sha256sum "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz"
```

The runtime needs a compatible NVIDIA driver and the CUDA runtime libraries,
but not Git, CMake, Ninja, CUDA headers, `nvcc` or a C/C++ compiler.

---

# Short Build Version

```bash
export LLAMA_CPP_TAG="b10218"
export CUDAARCHS="80-real;86-real;89-real;90-real;100a-real;120a-real"
export LLAMA_CPP_SOURCE="/workspace/llama.cpp"
export LLAMA_CPP_BUILD="/workspace/llama.cpp/build-cuda"
export LLAMA_CPP_PREFIX="/workspace/llama-cpp-dist"

cd /workspace
rm -rf "${LLAMA_CPP_SOURCE}" "${LLAMA_CPP_PREFIX}"

git clone --branch "${LLAMA_CPP_TAG}" --depth 1 \
    https://github.com/ggml-org/llama.cpp.git \
    "${LLAMA_CPP_SOURCE}"

cmake -S "${LLAMA_CPP_SOURCE}" -B "${LLAMA_CPP_BUILD}" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES="${CUDAARCHS}" \
    -DCMAKE_INSTALL_PREFIX="${LLAMA_CPP_PREFIX}" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH='$ORIGIN/../lib;$ORIGIN' \
    -DGGML_CUDA=ON \
    -DGGML_NATIVE=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON

cmake --build "${LLAMA_CPP_BUILD}" --config Release --parallel 16
cmake --install "${LLAMA_CPP_BUILD}" --config Release
```

---

# Short Verification Version

```bash
export LLAMA_CPP_PREFIX="/workspace/llama-cpp-dist"
export PATH="${LLAMA_CPP_PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${LLAMA_CPP_PREFIX}/lib:${LD_LIBRARY_PATH:-}"

llama-cli --version
llama-cli --list-devices

CUDA_SO=$(find "${LLAMA_CPP_PREFIX}" \
    -type f -name 'libggml-cuda.so*' -print -quit)
test -n "${CUDA_SO}"

for arch in sm_80 sm_86 sm_89 sm_90 sm_100a sm_120a; do
    cuobjdump --list-elf "${CUDA_SO}" | grep -q "${arch}" \
        && echo "OK ${arch}" \
        || exit 1
done
```

---

# Result

One pinned native `llama.cpp` build containing `llama-cli`, `llama-server`,
`llama-bench`, the shared libraries and native CUDA code for:

```text
SM80   -> Ampere data center
SM86   -> Ampere
SM89   -> Ada Lovelace
SM90   -> Hopper
SM100a -> Blackwell data center
SM120a -> Blackwell workstation/consumer
```
