#!/bin/bash

# VM Health Check Script
# Monitors CPU, memory, and disk space usage
# Declares VM healthy if all metrics are below 60% usage
# Target: Ubuntu virtual machines

set -euo pipefail

# Function to get CPU usage percentage
get_cpu_usage() {
    # Get CPU usage using vmstat (1 second interval, 2 samples, take the second one for accuracy)
    local cpu_idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
    local cpu_usage=$((100 - cpu_idle))
    echo $cpu_usage
}

# Function to get memory usage percentage
get_memory_usage() {
    # Get memory usage using free command
    local memory_info=$(free | grep '^Mem:')
    local total_mem=$(echo $memory_info | awk '{print $2}')
    local used_mem=$(echo $memory_info | awk '{print $3}')
    local memory_usage=$((used_mem * 100 / total_mem))
    echo $memory_usage
}

# Function to get disk usage percentage for root filesystem
get_disk_usage() {
    # Get disk usage for root filesystem
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo $disk_usage
}

# Function to determine health status
check_health() {
    local cpu_usage=$1
    local memory_usage=$2
    local disk_usage=$3
    local explain_mode=$4
    
    local threshold=60
    local is_healthy=true
    local reasons=()
    
    # Check each metric against threshold
    if [ $cpu_usage -gt $threshold ]; then
        is_healthy=false
        reasons+=("CPU usage is ${cpu_usage}% (above ${threshold}% threshold)")
    fi
    
    if [ $memory_usage -gt $threshold ]; then
        is_healthy=false
        reasons+=("Memory usage is ${memory_usage}% (above ${threshold}% threshold)")
    fi
    
    if [ $disk_usage -gt $threshold ]; then
        is_healthy=false
        reasons+=("Disk usage is ${disk_usage}% (above ${threshold}% threshold)")
    fi
    
    # Output health status
    if [ "$is_healthy" = true ]; then
        echo "VM Health Status: HEALTHY"
        if [ "$explain_mode" = true ]; then
            echo "Explanation: All system metrics are within acceptable limits:"
            echo "  - CPU usage: ${cpu_usage}% (below ${threshold}% threshold)"
            echo "  - Memory usage: ${memory_usage}% (below ${threshold}% threshold)" 
            echo "  - Disk usage: ${disk_usage}% (below ${threshold}% threshold)"
        fi
    else
        echo "VM Health Status: NOT HEALTHY"
        if [ "$explain_mode" = true ]; then
            echo "Explanation: One or more system metrics exceed the ${threshold}% threshold:"
            for reason in "${reasons[@]}"; do
                echo "  - $reason"
            done
            # Also show the healthy metrics for context
            if [ $cpu_usage -le $threshold ]; then
                echo "  - CPU usage: ${cpu_usage}% (within acceptable limits)"
            fi
            if [ $memory_usage -le $threshold ]; then
                echo "  - Memory usage: ${memory_usage}% (within acceptable limits)"
            fi
            if [ $disk_usage -le $threshold ]; then
                echo "  - Disk usage: ${disk_usage}% (within acceptable limits)"
            fi
        fi
    fi
}

# Main function
main() {
    local explain_mode=false
    
    # Check for explain argument
    if [ $# -gt 0 ] && [ "$1" = "explain" ]; then
        explain_mode=true
    elif [ $# -gt 0 ]; then
        echo "Usage: $0 [explain]"
        echo "  explain: Show detailed explanation of health status"
        exit 1
    fi
    
    # Verify we're running on Ubuntu (optional check)
    if [ -f /etc/os-release ]; then
        if ! grep -q "ubuntu" /etc/os-release 2>/dev/null; then
            echo "Warning: This script is designed for Ubuntu systems" >&2
        fi
    fi
    
    # Get system metrics
    echo "Collecting system metrics..."
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    
    # Display current metrics if in explain mode
    if [ "$explain_mode" = true ]; then
        echo "Current System Metrics:"
        echo "  CPU Usage: ${cpu_usage}%"
        echo "  Memory Usage: ${memory_usage}%"
        echo "  Disk Usage: ${disk_usage}%"
        echo ""
    fi
    
    # Check and report health status
    check_health $cpu_usage $memory_usage $disk_usage $explain_mode
}

# Run main function with all arguments
main "$@"
