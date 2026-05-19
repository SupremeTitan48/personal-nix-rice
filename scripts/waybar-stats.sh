#!/usr/bin/env bash
# waybar-stats — outputs JSON with CPU and RAM usage for the custom/stats module.
# CPU is sampled via top -bn1 (one-shot, no sleep needed).
# Output format: {"text":"...", "tooltip":"..."}

# --- CPU ---
cpu=$(top -bn1 | awk '/^%Cpu/{print int(100 - $8)}' 2>/dev/null || echo 0)

# --- RAM ---
mem_total=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
mem_avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
mem_used=$(( mem_total - mem_avail ))
mem_pct=$(( mem_used * 100 / mem_total ))
mem_gib=$(awk "BEGIN{printf \"%.1f\", $mem_used/1048576}")
mem_total_gib=$(awk "BEGIN{printf \"%.1f\", $mem_total/1048576}")

# --- Output ---
text="󰻠 ${cpu}%  ${mem_pct}%"
tooltip="CPU: ${cpu}%\nRAM: ${mem_gib}G / ${mem_total_gib}G"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
