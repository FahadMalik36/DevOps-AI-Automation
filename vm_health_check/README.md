# VM Health Check Script

This script monitors the health of Ubuntu virtual machines based on CPU, memory, and disk space utilization.

## Description

The `vm-health-check.sh` script analyzes three key system metrics:
- CPU usage percentage
- Memory usage percentage  
- Disk space usage percentage (root filesystem)

The VM is declared **HEALTHY** if all three metrics are below 60% utilization. If any metric exceeds 60%, the VM is declared **NOT HEALTHY**.

## Usage

```bash
# Basic health check
./vm-health-check.sh

# Health check with detailed explanation
./vm-health-check.sh explain
```

## Arguments

- `explain` (optional): Shows detailed explanation of the health status including current metric values and reasons for the health determination

## Output Examples

### Healthy VM
```
VM Health Status: HEALTHY
```

### Healthy VM with explanation
```
Current System Metrics:
  CPU Usage: 15%
  Memory Usage: 25%
  Disk Usage: 35%

VM Health Status: HEALTHY
Explanation: All system metrics are within acceptable limits:
  - CPU usage: 15% (below 60% threshold)
  - Memory usage: 25% (below 60% threshold)
  - Disk usage: 35% (below 60% threshold)
```

### Unhealthy VM with explanation
```
Current System Metrics:
  CPU Usage: 1%
  Memory Usage: 17%
  Disk Usage: 68%

VM Health Status: NOT HEALTHY
Explanation: One or more system metrics exceed the 60% threshold:
  - Disk usage is 68% (above 60% threshold)
  - CPU usage: 1% (within acceptable limits)
  - Memory usage: 17% (within acceptable limits)
```

## System Requirements

- Ubuntu operating system
- Standard system utilities: `vmstat`, `free`, `df`
- Bash shell

## Technical Details

- **CPU Usage**: Calculated using `vmstat` with a 1-second interval to get accurate real-time usage
- **Memory Usage**: Calculated using the `free` command to determine percentage of used memory
- **Disk Usage**: Calculated using `df` for the root filesystem (/) to check available disk space

The script uses a 60% threshold for all metrics and provides clear, actionable feedback about system health.