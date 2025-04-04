#!/bin/bash

# Script to kill all Adobe and Creative Cloud processes on macOS
# Features: better error handling, sudo check, verbose output, and process verification

# Text formatting
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Check if script is run with sudo
check_sudo() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}${BOLD}Warning:${RESET} This script may work better with sudo privileges."
    echo -e "Consider running: ${BLUE}sudo $0${RESET}"
    read -p "Continue without sudo? (y/n): " response
    if [[ "$response" != "y" ]]; then
      echo "Exiting..."
      exit 1
    fi
    echo "Continuing without sudo..."
  else
    echo -e "${GREEN}Running with sudo privileges.${RESET}"
  fi
}

# Function to kill processes by pattern
kill_process_by_pattern() {
  local pattern="$1"
  local count=0
  
  echo -e "\n${BOLD}Finding processes matching: ${BLUE}$pattern${RESET}"
  
  # Find PIDs
  local pids=$(pgrep -i "$pattern")
  
  if [ -z "$pids" ]; then
    echo -e "${YELLOW}No processes found matching '$pattern'${RESET}"
    return 0
  fi
  
  # Get process names for display
  echo -e "${BOLD}Found the following processes:${RESET}"
  for pid in $pids; do
    local pname=$(ps -p $pid -o comm= 2>/dev/null)
    if [ -n "$pname" ]; then
      echo -e "  ${BOLD}PID:${RESET} $pid - ${BOLD}Process:${RESET} $pname"
      count=$((count + 1))
    fi
  done
  
  # Kill the processes
  echo -e "${BOLD}Terminating processes...${RESET}"
  pkill -9 -i "$pattern"
  
  # Verify termination
  sleep 0.5
  local remaining=$(pgrep -i "$pattern")
  if [ -z "$remaining" ]; then
    echo -e "${GREEN}Successfully terminated $count process(es) matching '$pattern'.${RESET}"
  else
    echo -e "${RED}Warning: Some processes matching '$pattern' could not be terminated.${RESET}"
    echo -e "${RED}You may need sudo privileges to kill these processes.${RESET}"
  fi
}

# Function to kill specific processes by name
kill_specific_processes() {
  local processes=("$@")
  local killed=0
  local failed=0
  
  echo -e "\n${BOLD}Processing specific Adobe processes...${RESET}"
  
  for process in "${processes[@]}"; do
    local pids=$(pgrep -i "$process")
    if [ -n "$pids" ]; then
      echo -e "${BOLD}Found process: ${BLUE}$process${RESET}"
      if pkill -9 -i "$process"; then
        echo -e "${GREEN}Successfully terminated '$process'.${RESET}"
        killed=$((killed + 1))
      else
        echo -e "${RED}Failed to terminate '$process'.${RESET}"
        failed=$((failed + 1))
      fi
    fi
  done
  
  echo -e "${BOLD}Results:${RESET} Terminated $killed process(es), failed to terminate $failed process(es)."
}

# Function to find and kill remaining Adobe processes
kill_remaining_adobe_processes() {
  echo -e "\n${BOLD}Searching for any remaining Adobe-related processes...${RESET}"
  
  # Find remaining processes
  local remaining=$(ps aux | grep -i "adobe\|creative cloud" | grep -v grep | grep -v "$0")
  
  if [ -z "$remaining" ]; then
    echo -e "${GREEN}No remaining Adobe processes found.${RESET}"
    return 0
  fi
  
  echo -e "${BOLD}Found these remaining Adobe-related processes:${RESET}"
  echo "$remaining" | while read line; do
    local pid=$(echo "$line" | awk '{print $2}')
    local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) print $i}')
    echo -e "  ${BOLD}PID:${RESET} $pid - ${BOLD}Command:${RESET} $cmd"
  done
  
  # Extract PIDs and kill them
  local pids=$(echo "$remaining" | awk '{print $2}')
  if [ -n "$pids" ]; then
    echo -e "${BOLD}Attempting to terminate remaining processes...${RESET}"
    for pid in $pids; do
      if kill -9 $pid 2>/dev/null; then
        echo -e "${GREEN}Terminated process with PID $pid.${RESET}"
      else
        echo -e "${RED}Failed to terminate process with PID $pid.${RESET}"
      fi
    done
  fi
}

# Function to verify no Adobe processes remain
verify_no_adobe_processes() {
  echo -e "\n${BOLD}Verifying all Adobe processes are terminated...${RESET}"
  
  local remaining=$(ps aux | grep -i "adobe\|creative cloud" | grep -v grep | grep -v "kill-adobe.sh")
  
  if [ -z "$remaining" ]; then
    echo -e "${GREEN}${BOLD}Success:${RESET}${GREEN} No Adobe processes found running on the system.${RESET}"
    return 0
  else
    echo -e "${RED}${BOLD}Warning:${RESET}${RED} Some Adobe processes still remain:${RESET}"
    echo "$remaining" | while read line; do
      local pid=$(echo "$line" | awk '{print $2}')
      local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) print $i}')
      echo -e "  ${BOLD}PID:${RESET} $pid - ${BOLD}Command:${RESET} $cmd"
    done
    return 1
  fi
}

# Main execution
echo -e "${BOLD}${BLUE}Adobe Process Terminator${RESET}"
echo -e "${BOLD}----------------------------${RESET}"
echo -e "Starting cleanup of Adobe and Creative Cloud processes...\n"

# Check for sudo
check_sudo

# List of known Adobe background processes
ADOBE_PROCESSES=(
  "CCXProcess" 
  "CCLibrary" 
  "Adobe Desktop Service" 
  "Adobe Crash Reporter" 
  "AdobeIPCBroker" 
  "Adobe CEF Helper"
  "CoreSync"
  "ACCFinderSync"
  "AdobeUpdateService"
  "Creative Cloud Helper"
  "Adobe Crash Handler"
  "Adobe Install Manager"
  "Adobe Notification Client"
  "AdobeResourceSynchronizer"
)

# Kill main Adobe processes
kill_process_by_pattern "Adobe"
kill_process_by_pattern "Creative Cloud"

# Kill specific known background processes
kill_specific_processes "${ADOBE_PROCESSES[@]}"

# Find and kill any remaining Adobe processes
kill_remaining_adobe_processes

# Verify all Adobe processes are terminated
verify_no_adobe_processes

echo -e "\n${BOLD}${GREEN}Process complete!${RESET}"
echo -e "If you still have issues with Adobe processes, consider rebooting your Mac."