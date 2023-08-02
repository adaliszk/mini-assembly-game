#!/usr/bin/env bash

if [[ -f ".git/PROJECT_INITIALIZED" ]]; then
	echo "This repository has already been initialized, skipping..."
	exit 0
fi

SCRIPT="git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short HEAD > git_version.txt"

echo "${SCRIPT}" >> ".git/hooks/post-checkout"
echo "${SCRIPT}" >> ".git/hooks/post-commit"

bash -c .git/hooks/post-commit
touch .git/PROJECT_INITIALIZED
