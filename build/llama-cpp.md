# Build llama-cpp wheel with CUDA support

- [Github](https://github.com/abetlen/llama-cpp-python)

## Set your GPU CUDA archs to speed up the build & reduce wheel size

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

## If you are lazy

```bash
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu124
```