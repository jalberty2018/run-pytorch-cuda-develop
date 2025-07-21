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
for script in readme-on-workspace.sh build-on-workspace.sh; do
    if [ -f "/$script" ]; then
        echo "Executing $script..."
        "/$script"
    else
        echo "WARNING: Skipping $script (not found)"
    fi
done

# Run service
if [[ ${RUNPOD_GPU_COUNT:-0} -gt 0 ]]; then
    if [[ -n "$PASSWORD" ]]; then
    code-server /workspace --auth password --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    else
    echo "WARNING: PASSWORD is not set as an environment variable - code-server not started"
    fi
	
	sleep 5
	
	if [[ -n "$JUPYTERLAB_PASS" ]]; then	
    export HASHED=$(python3 -c 'import hashlib, random, string, sys; password = sys.argv[1]; salt = "".join(random.choices(string.ascii_letters + string.digits, k=8)); h = hashlib.sha1(); h.update((password + salt).encode("utf-8")); print("sha1:" + salt + ":" + h.hexdigest())' "$JUPYTERLAB_PASS")

    cat > /root/.jupyter/jupyter_server_config.py <<EOF
c.PasswordIdentityProvider.hashed_password = '${HASHED}'
c.TerminalManager.enabled = True
EOF

    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.allow_origin='*' --ServerApp.allow_remote_access=True &
    else
    echo "WARNING: JUPYTERLAB_PASS is not set as an environment variable - jupyterlab not started"
    fi	
else
    echo "WARNING: No GPU available, Services not started to limit memory use"
fi
	
# Final message
echo "[INFO] Ready, end script"

# Keep the container running
exec sleep infinity
