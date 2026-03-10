# Build llama-cpp wheel with CUDA support (Qwen3 VL support) ?????

- [llama-cpp-python](https://github.com/JamePeng/llama-cpp-python)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

## Compiler settings A40, L40S

```bash
export CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=86;89"
export CUDAARCHS="86;89"         
export FORCE_CMAKE=1
```

## Clone

```bash
git clone https://github.com/JamePeng/llama-cpp-python.git
cd llama-cpp-python/vendor
rm -rf llama.cpp
git clone https://github.com/ggml-org/llama.cpp.git
cd ..
```

## Compile

```bash
export CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=86;89"
export CUDAARCHS="86;89"
export FORCE_CMAKE=1

python -m pip wheel --no-cache-dir \
  --no-binary llama-cpp-python \
  --wheel-dir wheelhouse \
  llama-cpp-python==0.3.17
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

```bash
python - <<'PY'
import llama_cpp
print("llama-cpp-python version:", llama_cpp.__version__)
try:
    from llama_cpp import llama_print_system_info
    info = llama_print_system_info()
    print(info.decode('utf-8'))
except Exception as e2:
    print("Failed:", e2)
PY
```

## Test (0.3.17)

```bash
export LLAMA_LOG_LEVEL=info
export GGML_CUDA_FORCE_MMQ=1

hf download TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF tinyllama-1.1b-chat-v1.0.Q8_0.gguf --local-dir=/workspace

python /workspace/build/test_llama-cpp.py
```
