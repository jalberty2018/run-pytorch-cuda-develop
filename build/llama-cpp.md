# Build llama-cpp wheel with CUDA support

- [github](https://github.com/abetlen/llama-cpp-python)

## Set your GPU CUDA archs to speed up the build & reduce wheel size

- [architecture](https://developer.nvidia.com/cuda-gpus)

- 86 = RTX A5000 & A40
- 89 = L40S
- 90 = H100/H200

## Compile

```bash
export CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=86;89"         
export FORCE_CMAKE=1

python -m pip wheel --no-cache-dir \
  --no-binary llama-cpp-python \
  --wheel-dir wheelhouse \
  llama-cpp-python
```

## Install

```bash
python -m pip install ./wheelhouse/llama_cpp_python-*.whl
```

## Sanity check

```bash
python - <<'PY'
import llama_cpp, sys
info = llama_cpp.llama_cpp.llama_print_system_info().decode()
print(info)
print("\nOK: saw 'CUDA' in system info?" , "CUDA" in info)
PY
```

## Test

```bash
export LLAMA_LOG_LEVEL=info
export GGML_CUDA_FORCE_MMQ=1

hf download TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF tinyllama-1.1b-chat-v1.0.Q8_0.gguf --local-dir=/workspace

python /workspace/build/test_llama-cpp.py
```

## Install wheel on other system

```bash
find / -name "libcudart.so*" 2>/dev/null
```

```bash
wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/llama_cpp_python-0.3.16-cp311-cp311-linux_x86_64.whl
pip install llama_cpp_python-0.3.16-cp311-cp311-linux_x86_64.whl
rm llama_cpp_python-0.3.16-cp311-cp311-linux_x86_64.whl
echo "/opt/conda/lib/python3.11/site-packages/nvidia/cuda_runtime/lib" > /etc/ld.so.conf.d/cuda-runtime.conf
echo "/opt/conda/lib/python3.11/site-packages/nvidia/cublas/lib" > /etc/ld.so.conf.d/cublas.conf
ldconfig
```

## If you are lazy

```bash
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu124
```