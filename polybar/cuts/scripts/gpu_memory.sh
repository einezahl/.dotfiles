#!/bin/bash

# Script to fetch GPU memory usage using nvidia-smi
gpu_memory_usage() {
  nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{print $1"MiB"}'
}

gpu_memory_usage
