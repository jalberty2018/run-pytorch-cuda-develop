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
	echo "⚠️ WARNING: HF_TOKEN is not set as an environment variable"
fi

# Create output directory for cloud transfer
mkdir -p /workspace/output/

# Move necessary files to workspace
for script in readme-on-workspace.sh build-on-workspace.sh; do
    if [ -f "/$script" ]; then
        echo "Executing $script..."
        "/$script"
    else
        echo "⚠️ WARNING: Skipping $script (not found)"
    fi
done

# Run service
if [[ ${RUNPOD_GPU_COUNT:-0} -gt 0 ]]; then
    if [[ -n "$PASSWORD" ]]; then
    code-server /workspace --auth password --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    else
    echo "⚠️ WARNING: PASSWORD is not set as an environment variable - code-server not started"
    fi
	
	sleep 5
	
	#!/bin/bash

	if [[ -n "$JUPYTERLAB_PASS" ]]; then
    # Use Python to hash the password
    HASHED_PASSWORD=$(python3 -c "
import os
from jupyter_server.auth import passwd
print(passwd(os.environ['JUPYTERLAB_PASS']))
")

    # Path to Jupyter config
    CONFIG_PATH=~/.jupyter/jupyter_server_config.py

    # Ensure config directory exists
    mkdir -p ~/.jupyter

    # Remove any existing password setting
    sed -i '/^c.ServerApp.password/d' "$CONFIG_PATH" 2>/dev/null || true

    # Append the new hashed password
    echo "c.ServerApp.password = u'$HASHED_PASSWORD'" >> "$CONFIG_PATH"
    echo "✅ Jupyter Server password set in $CONFIG_PATH"

    # Start JupyterLab
    jupyter lab \
        --ip=0.0.0.0 \
        --port=8888 \
        --no-browser \
        --allow-root \
        --ServerApp.allow_origin='*' \
        --ServerApp.allow_remote_access=True &
	else
    echo "⚠️ WARNING: JUPYTERLAB_PASS is not set as an environment variable - JupyterLab not started"
	fi
else
    echo "⚠️ WARNING: No GPU available, Services not started to limit memory use"
fi
	
# Final message
echo "✅ [INFO] Ready, end script"

# Keep the container running
exec sleep infinity
