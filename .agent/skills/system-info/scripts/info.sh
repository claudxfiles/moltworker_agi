#!/bin/bash
echo "--- Sandbox System Info ---"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -a)"
echo "Uptime: $(uptime)"
echo "Memory:"
free -h
echo "Disk Usage:"
df -h
echo "---------------------------"
