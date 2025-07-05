#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -f /workspace/README.md ]]
then
	mv /README.md /workspace/README.md
else
	rm -f /README.md
fi
