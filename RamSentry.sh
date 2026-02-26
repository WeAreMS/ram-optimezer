#!/bin/bash

# Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- INITIALIZATION ---
clear
echo -e "${CYAN}>>> Initializing Ram-Optimizer Pro...${NC}"
echo -e "${YELLOW}>>> Installing dependencies (psutil, sensors, cpufreq)...${NC}"

# Auto-install dependencies
sudo apt update -y && sudo apt install -y python3-psutil figlet lm-sensors cpufrequtils neofetch

# --- CORE FUNCTIONS ---

s_direct_cooler() {
    echo -e "${RED}[!!!] S-DIRECT COOLER ACTIVATED [!!!]${NC}"
    sudo cpufreq-set -g powersave
    sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    sudo swapoff -a && sudo swapon -a
    echo -e "${GREEN}[+] Cooling initiated. CPU throttled and RAM purged.${NC}"
}

purge_ram() {
    echo -e "${BLUE}>>> Purging RAM (Aggressive Mode)...${NC}"
    sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    sudo swapoff -a && sudo swapon -a
    echo -e "${GREEN}[+] RAM usage successfully reduced.${NC}"
}

# --- MAIN INTERFACE ---
while true; do
    clear
    figlet -f small "Ram-Optimizer"
    
    # Get Live Stats
    TEMP=$(sensors | grep "Core 0" | awk '{print $3}' | cut -c2-3)
    RAM_PCT=$(free | grep Mem | awk '{print int($3/$2 * 100.0)}')
    
    echo -e "${RED}TEMP: ${TEMP}°C ${NC}| ${BLUE}RAM: ${RAM_PCT}%${NC} | ${CYAN}ARCH: i686${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo -e " 1) ${RED}S-DIRECT COOLER${NC} (Aggressive Cooling)"
    echo -e " 2) ${GREEN}AUTO-GUARD${NC} (7/24 Monitor & Fix)"
    echo -e " 3) ${YELLOW}PURGE RAM NOW${NC} (Immediate Drop)"
    echo -e " 4) ${CYAN}SYSTEM CLEANUP${NC} (Logs & Cache)"
    echo -e " 5) PERFORMANCE MODE (High Speed)"
    echo -e " 6) EXIT"
    echo -e "${BLUE}=======================================${NC}"
    read -p "Selection: " opt

    case $opt in
        1) s_direct_cooler; sleep 3 ;;
        2)
            sudo python3 -c "
import psutil, time, os
print('--- AUTO-GUARD ACTIVE (Ctrl+C to stop) ---')
try:
    while True:
        ram = psutil.virtual_memory().percent
        temp = float(os.popen('sensors | grep \"Core 0\" | awk \"{print \$3}\"').read().strip().replace('°C', '').replace('+', ''))
        print(f'\rTEMP: {temp}°C | RAM: {ram}%', end='', flush=True)
        if temp > 75 or ram > 70:
            os.system('cpufreq-set -g powersave')
            os.system('sync; echo 3 > /proc/sys/vm/drop_caches; swapoff -a; swapon -a')
        time.sleep(5)
except KeyboardInterrupt: pass
"
            ;;
        3) purge_ram; sleep 2 ;;
        4) 
            sudo journalctl --vacuum-time=1s
            sudo apt clean
            echo -e "${GREEN}Cleanup complete!${NC}"; sleep 2 ;;
        5) 
            sudo cpufreq-set -g performance
            echo -e "${YELLOW}Performance Mode Active!${NC}"; sleep 2 ;;
        6) exit 0 ;;
    esac
done
