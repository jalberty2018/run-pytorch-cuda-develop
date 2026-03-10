# torch_generic_nms

- [Website](https://github.com/ronghanghu/torch_generic_nms)
- [SAM3](https://github.com/PozzettiAndrea/ComfyUI-SAM3)
 
## Build wheel

```bash
git clone https://github.com/ronghanghu/torch_generic_nms.git
cd torch_generic_nms
```

```bash
export CUDAARCHS=“80;86;89;90;120”
export CMAKE_ARGS=“-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=$CUDAARCHS”
export FORCE_CMAKE=1

MAX_JOBS=16 python -m build --wheel --no-isolation
```
 
## Install wheel

```bash
pip install dist/torch_generic_nms-0.1-*.whl
```

## Test wheel
 
```bash
python /workspace/build/test_torch_generic_nms.py
```

### Output 

/opt/conda/lib/python3.11/site-packages/torch_generic_nms/__init__.py

```python
torchvision_result = torchvision.ops.nms(boxes, scores, iou_threshold)
print(torchvision_result)
```

    tensor([89, 68, 44, 12, 97, 57, 88, 70, 69, 24, 47, 48, 43, 72, 41, 14,  1, 35,
            23, 71, 33, 86, 80, 75, 30, 64, 96, 17, 62, 13, 91,  9, 90, 54, 29, 61,
            55, 79, 53, 25, 58, 83, 39,  2,  3, 93, 37, 95, 42, 20, 60, 94, 31, 73,
            87, 26, 38,  4, 98, 56,  0, 10, 40, 78, 28, 21, 36, 81, 11, 32, 16, 99,
             7, 15, 45,  8, 65, 76, 67, 74, 82, 84, 59, 85, 19, 18, 77, 63, 46, 22,
            49, 52, 66,  5,  6, 51], device='cuda:0')

```python
generic_result_box = torch_generic_nms.generic_nms(boxes, scores, iou_threshold, use_iou_matrix=False)
print(generic_result_box)
```

    tensor([89, 68, 44, 12, 97, 57, 88, 70, 69, 24, 47, 48, 43, 72, 41, 14,  1, 35,
            23, 71, 33, 86, 80, 75, 30, 64, 96, 17, 62, 13, 91,  9, 90, 54, 29, 61,
            55, 79, 53, 25, 58, 83, 39,  2,  3, 93, 37, 95, 42, 20, 60, 94, 31, 73,
            87, 26, 38,  4, 98, 56,  0, 10, 40, 78, 28, 21, 36, 81, 11, 32, 16, 99,
             7, 15, 45,  8, 65, 76, 67, 74, 82, 84, 59, 85, 19, 18, 77, 63, 46, 22,
            49, 52, 66,  5,  6, 51], device='cuda:0')

```python
ious = torchvision.ops.box_iou(boxes, boxes)
generic_result_iou = torch_generic_nms.generic_nms(ious, scores, iou_threshold, use_iou_matrix=True)
print(generic_result_iou)
```

    tensor([89, 68, 44, 12, 97, 57, 88, 70, 69, 24, 47, 48, 43, 72, 41, 14,  1, 35,
            23, 71, 33, 86, 80, 75, 30, 64, 96, 17, 62, 13, 91,  9, 90, 54, 29, 61,
            55, 79, 53, 25, 58, 83, 39,  2,  3, 93, 37, 95, 42, 20, 60, 94, 31, 73,
            87, 26, 38,  4, 98, 56,  0, 10, 40, 78, 28, 21, 36, 81, 11, 32, 16, 99,
             7, 15, 45,  8, 65, 76, 67, 74, 82, 84, 59, 85, 19, 18, 77, 63, 46, 22,
            49, 52, 66,  5,  6, 51], device='cuda:0')
