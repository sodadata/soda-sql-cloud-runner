#!/usr/bin/env bash
set -e

# Disable strict host checking for versatile repository support
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

EXEC_DIR="/opt/sodasql"

if [ -z "$REPO_URI" ]; then
  echo "Expects REPO_URI to be provided as env var. See https://github.com/sodadata/soda-cloud-runner for more information"
  exit 1
fi

if [ -z "$SCAN_CMD" ]; then
  echo "Expects SCAN_CMD to be provided as env var. See https://github.com/sodadata/soda-cloud-runner for more information"
  exit 1
fi

if [ "$RSA_KEY_CONTENTS" ]; then
  echo "Private RSA Key Contents provided, setting identity"
  mkdir -p ~/.ssh
  echo "${RSA_KEY_CONTENTS}" > ~/.ssh/id_rsa
  chmod 0600 ~/.ssh/id_rsa
else
  echo "No Private Key provided, can only scan public repositories"
fi

# Clone repo and change into it
git clone --depth=1 $REPO_URI $EXEC_DIR
cd $EXEC_DIR

# In case the repository contains a different working directory
if [ "$WORKING_DIR" ]; then
  cd $WORKING_DIR
fi

# Install requirements
pip install --upgrade pip
pip install --upgrade -r requirements.txt

# Execute scan command
soda scan $SCAN_CMD