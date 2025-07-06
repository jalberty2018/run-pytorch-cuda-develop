#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/build ]]
then
	mv /build /workspace
	# Set permissions right for directory
    chmod -R 777 /workspace/build
else
	rm -rf /build
fi

# Linking
ln -s /workspace/build /build
