#!/bin/bash
set -e

echo "# Update and install dependences "
sudo apt update
sudo apt install -y \
  verilator \
  googletest \
  lcov \
  gtkwave

echo "# Verify installation "
echo "# Verilator version: "
verilator --version

echo "# Setup finished "
