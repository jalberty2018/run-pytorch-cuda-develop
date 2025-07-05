#!/bin/bash

echo "[INFO] run-pytorch-cuda-develop pod started"

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

# Login to Hugging Face if token is provided
if [[ -n "$HF_TOKEN" ]]; then
    huggingface-cli login --token "$HF_TOKEN"
	sleep 1
else
	echo "WARNING: HF_TOKEN is not set as an environment variable"
fi

# Create output directory for cloud transfer
mkdir -p /workspace/output/

# Move necessary files to workspace
for script in readme-on-workspace.sh; do
    if [ -f "/$script" ]; then
        echo "Executing $script..."
        "/$script"
    else
        echo "WARNING: Skipping $script (not found)"
    fi
done

# Run service
if [[ ${RUNPOD_GPU_COUNT:-0} -gt 0 ]]; then
    # Start code-server (HTTP port 9000)
    if [[ -n "$PASSWORD" ]]; then
        code-server /workspace --auth password --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    else
        echo "WARNING: PASSWORD is not set as an environment variable"
        code-server /workspace --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    fi

	# Confirmation	
	echo "[INFO] Code Server started"
	
else
    echo "WARNING: No GPU available, Code Server not started to limit memory use"
fi
	
# Final message
echo "[INFO] Ready end script"

# Keep the container running
exec sleep infinity
