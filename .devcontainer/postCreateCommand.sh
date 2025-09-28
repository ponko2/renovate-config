#!/usr/bin/env bash

set -euo pipefail

git config --global --add safe.directory /workspaces/renovate-config

sudo apt update
sudo apt install -y yamllint

pnpm install --force
