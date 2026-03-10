# Block Sparse Attention Wheel

## Official

- [Github](https://github.com/mit-han-lab/Block-Sparse-Attention)

## A40, L40S

```bash
export TORCH_CUDA_ARCH_LIST="8.6;8.9"
export USE_NINJA=1
```

## Clone

```bash
git clone https://github.com/mit-han-lab/Block-Sparse-Attention
```

## Clean

```bash
cd Block-Sparse-Attention
rm -rf build/ dist/ *.egg-info
```

## Build wheel

```bash
python setup.py bdist_wheel
```

## Install & Check

```bash
pip install /workspace/Block-Sparse-Attention/dist/block_sparse_attn-0*.whl
cd /workspace/Block-Sparse-Attention/block_sparse_tests/fwd/test_correctness

cd /workspace/Block-Sparse-Attention/block_sparse_tests/fwd/test_performance/
python token_streaming.py
python blocksparse.py

pytest full_test.py
```
