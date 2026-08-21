# Install a Pre-built llama.cpp CUDA Build in Docker

This guide packages the native binaries built with
[`llama-cpp.md`](llama-cpp.md) and installs them in another Docker image for
use in a pod. The Docker image does not compile `llama.cpp` and does not need
CMake, Ninja, `nvcc` or a C/C++ compiler.

## Prerequisites

The native build must already exist in the build pod:

```text
/workspace/llama.cpp/build-cuda/
```

The target image must provide a compatible NVIDIA CUDA 12.8 runtime. The host
running the pod must provide a compatible NVIDIA driver and expose the GPU to
the container.

The procedure is compatible with `pytorch-cuda-ubuntu-runtime` and
`comfyui-runtime2`. The latter already contains `llama-cpp-python` 0.3.34. The
native installation and Python wheel must keep using their own shared
libraries because they can contain different `llama.cpp` revisions.

Do not globally set either of these variables in the target image:

```dockerfile
ENV LD_LIBRARY_PATH="/opt/llama.cpp/lib:${LD_LIBRARY_PATH}"
ENV LLAMA_CPP_LIB_PATH="/opt/llama.cpp/lib"
```

Do not add `/opt/llama.cpp/lib` to `/etc/ld.so.conf` or
`/etc/ld.so.conf.d/`. The native binaries built with `llama-cpp.md` use their
embedded relative RPATH, while `llama-cpp-python` loads its package-local
libraries.

---

## Collect the Compiled Files

Run these commands in the build pod. `cmake --install` does not compile the
project again; it only collects the existing binaries, shared libraries and
supporting files in a portable directory.

```bash
export LLAMA_CPP_BUILD="/workspace/llama.cpp/build-cuda"
export LLAMA_CPP_PREFIX="/workspace/llama-cpp-dist"
export LLAMA_CPP_TAG="b10218"

cmake \
    --install "${LLAMA_CPP_BUILD}" \
    --prefix "${LLAMA_CPP_PREFIX}" \
    --config Release
```

Inspect the collected files:

```bash
find "${LLAMA_CPP_PREFIX}" -maxdepth 2 -type f \
    | sort
```

At minimum, verify the command-line application and CUDA backend:

```bash
test -x "${LLAMA_CPP_PREFIX}/bin/llama-cli"

CUDA_SO=$(find "${LLAMA_CPP_PREFIX}" \
    -type f -name 'libggml-cuda.so*' -print -quit)

test -n "${CUDA_SO}"
echo "${CUDA_SO}"
```

Verify that the native executable contains the relative runtime library path
configured by `llama-cpp.md`:

```bash
readelf -d "${LLAMA_CPP_PREFIX}/bin/llama-cli" \
    | grep -E '(RPATH|RUNPATH).*(\$ORIGIN/../lib|\$ORIGIN)'
```

Do not package the build if this check fails. Rebuild it with the documented
`CMAKE_INSTALL_RPATH` settings first.

---

## Create the Archive

Create the archive in `/workspace`:

```bash
tar \
    -C "${LLAMA_CPP_PREFIX}" \
    -czf "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz" \
    .
```

Generate a checksum and inspect the result:

```bash
ls -lh "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz"
sha256sum "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz"
tar -tzf "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz"
```

The resulting file is:

```text
/workspace/llama-cpp-b10218-cu128-linux-x86_64.tar.gz
```

The archive should contain files such as:

```text
./bin/llama-cli
./bin/llama-server
./bin/llama-bench
./lib/libllama.so
./lib/libggml.so
./lib/libggml-cuda.so
```

Versioned shared-library filenames or symbolic links may also be present.

---

## Add the Archive to the Docker Build Context

Download or copy the archive from the build pod and place it next to the
Dockerfile of the target image:

```text
target-image/
├── Dockerfile
└── llama-cpp-b10218-cu128-linux-x86_64.tar.gz
```

Make sure `.dockerignore` does not exclude the archive.

---

## Install the Archive in the Dockerfile

Add the following instructions to the target Dockerfile:

```dockerfile
ARG LLAMA_CPP_TAG=b10218

COPY llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz \
    /tmp/llama-cpp.tar.gz

RUN mkdir -p /opt/llama.cpp \
 && tar -xzf /tmp/llama-cpp.tar.gz -C /opt/llama.cpp \
 && rm /tmp/llama-cpp.tar.gz \
 && test -x /opt/llama.cpp/bin/llama-cli \
 && find /opt/llama.cpp -type f -name 'libggml-cuda.so*' -print -quit \
    | grep -q .

ENV PATH="/opt/llama.cpp/bin:${PATH}"
```

This extraction is the complete installation. Do not run `pip install`, CMake
configuration or compilation in the target image.

Only prepend `/opt/llama.cpp/bin` to `PATH`. Keep the target image's inherited
`LD_LIBRARY_PATH` unchanged and leave `LLAMA_CPP_LIB_PATH` unset. This preserves
the CUDA and Conda paths inherited from the PyTorch base image and prevents the
native `libllama` or `libggml` libraries from overriding those bundled with
`llama-cpp-python`.

---

## Build the Docker Image

From the directory containing the Dockerfile and archive:

```bash
docker build \
    --tag llama-cpp-cu128:b10218 \
    .
```

---

## Verify the Image

Check the installed binaries without requiring a GPU:

```bash
docker run --rm \
    llama-cpp-cu128:b10218 \
    llama-cli --version
```

Check CUDA discovery on a GPU host:

```bash
docker run --rm \
    --gpus all \
    llama-cpp-cu128:b10218 \
    llama-cli --list-devices
```

The second command must list the NVIDIA CUDA device. If a shared library is
missing, inspect the executable dependencies inside the image:

```bash
docker run --rm \
    llama-cpp-cu128:b10218 \
    ldd /opt/llama.cpp/bin/llama-cli
```

No dependency should be reported as `not found`.

### Verify together with llama-cpp-python

For an image such as `comfyui-runtime2`, check both installations during the
Docker build without requiring a GPU:

```dockerfile
RUN llama-cli --version \
 && python -c "import llama_cpp; print(llama_cpp.__version__, llama_cpp.__file__)"
```

In the running GPU pod, verify both CUDA backends separately:

```bash
llama-cli --list-devices

python - <<'PY'
import llama_cpp

print("llama-cpp-python:", llama_cpp.__version__)
print("Package:", llama_cpp.__file__)
print(llama_cpp.llama_cpp.llama_print_system_info().decode())
PY
```

Both checks must report CUDA. The Python package path must point to
`site-packages/llama_cpp`, not `/opt/llama.cpp`.

Both implementations may run simultaneously as separate processes, but each
creates its own CUDA context and model allocation. Size models and concurrency
so their combined use fits in GPU memory.

---

# Short Version

In the build pod:

```bash
export LLAMA_CPP_TAG="b10218"
export LLAMA_CPP_BUILD="/workspace/llama.cpp/build-cuda"
export LLAMA_CPP_PREFIX="/workspace/llama-cpp-dist"

cmake --install "${LLAMA_CPP_BUILD}" \
    --prefix "${LLAMA_CPP_PREFIX}" \
    --config Release

tar -C "${LLAMA_CPP_PREFIX}" \
    -czf "/workspace/llama-cpp-${LLAMA_CPP_TAG}-cu128-linux-x86_64.tar.gz" \
    .
```

In the target Dockerfile:

```dockerfile
COPY llama-cpp-b10218-cu128-linux-x86_64.tar.gz /tmp/llama-cpp.tar.gz

RUN mkdir -p /opt/llama.cpp \
 && tar -xzf /tmp/llama-cpp.tar.gz -C /opt/llama.cpp \
 && rm /tmp/llama-cpp.tar.gz

ENV PATH="/opt/llama.cpp/bin:${PATH}"
```
