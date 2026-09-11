#!/usr/bin/env bash
# Apply NVIDIA power and clock optimizations if an NVIDIA GPU and driver are present
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi -pm 1 2>/dev/null || true
    nvidia-smi -lgc 800,2450 2>/dev/null || true
fi
