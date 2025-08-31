from llama_cpp import Llama

MODEL = "/workspace/tinyllama-1.1b-chat-v1.0.Q8_0.gguf"  

llm = Llama(
    model_path=MODEL,
    n_gpu_layers=-1,        # offload all layers that fit to GPU
    main_gpu=0,             # use GPU 0
    n_ctx=2048,             # context size
    logits_all=False,
)

prompt = "Hello i am pytorch who are you"
out = llm(prompt, max_tokens=128, temperature=0.5, echo=False)
print(out["choices"][0]["text"])