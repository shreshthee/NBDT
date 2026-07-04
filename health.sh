
#!/bin/sh
#
# Nokia Beacon Diagnostic Toolkit
# health.sh
# Version : 1.0
#

. /opt/nbdt/lib/common.sh

header "Health Status"

############################################
# CPU Thermal Zones
############################################

CPU0=$(awk '{print int($1/1000)}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
CPU1=$(awk '{print int($1/1000)}' /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
CPU2=$(awk '{print int($1/1000)}' /sys/class/thermal/thermal_zone2/temp 2>/dev/null)
CPU3=$(awk '{print int($1/1000)}' /sys/class/thermal/thermal_zone3/temp 2>/dev/null)

############################################
# Memory
############################################

MEM_TOTAL=$(free | awk '/Mem:/ {print int($2/1024)}')
MEM_USED=$(free | awk '/Mem:/ {print int($3/1024)}')
MEM_FREE=$(free | awk '/Mem:/ {print int($4/1024)}')
MEM_SHARED=$(free | awk '/Mem:/ {print int($5/1024)}')
MEM_CACHE=$(free | awk '/Mem:/ {print int($6/1024)}')
MEM_AVAIL=$(free | awk '/Mem:/ {print int($7/1024)}')
############################################
# CPU Frequency
############################################

CPU_FREQ=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq 2>/dev/null | awk '{print int($1/1000)}')
############################################
# CPU Load
############################################

LOAD=$(awk '{print $1}' /proc/loadavg)

############################################
# Process Count
############################################

PROC=$(ps | wc -l)

############################################
# Uptime
############################################

UP=$(cut -d. -f1 /proc/uptime)

DAY=$((UP/86400))
HOUR=$(((UP%86400)/3600))
MIN=$(((UP%3600)/60))

############################################
# Storage
############################################

OPT=$(df -h | awk '$6=="/opt"{print $5}')
LOGS=$(df -h | awk '$6=="/logs"{print $5}')
CFG=$(df -h | awk '$6=="/configs"{print $5}')
BACKUP=$(df -h | awk '$6=="/backup"{print $5}')
############################################
# ===== STOP =====
# Part-2 starts from here
############################################
############################################
# Network
############################################

if ip route | grep -q "^default"
then
    WAN="Connected"
else
    WAN="Disconnected"
fi
############################################
# Connected Clients
############################################

CLIENT24=$(wlanconfig ath0 list 2>/dev/null | grep '^..:..:..:..:..:..' | wc -l)
CLIENT5=$(wlanconfig ath1 list 2>/dev/null | grep '^..:..:..:..:..:..' | wc -l)

TOTAL_CLIENTS=$((CLIENT24 + CLIENT5))
############################################
# WiFi Radios
############################################

if iw dev | grep -q "Interface ath0"
then
    WIFI24="UP"
else
    WIFI24="DOWN"
fi

if iw dev | grep -q "Interface ath1"
then
    WIFI5="UP"
else
    WIFI5="DOWN"
fi

############################################
# Temperature Status
############################################

temp_status()
{
    T=$1

    if [ "$T" -lt 60 ]
    then
        echo "OK"
    elif [ "$T" -lt 75 ]
    then
        echo "WARM"
    else
        echo "HOT"
    fi
}

CPU0_STATE=$(temp_status "$CPU0")
CPU1_STATE=$(temp_status "$CPU1")
CPU2_STATE=$(temp_status "$CPU2")
CPU3_STATE=$(temp_status "$CPU3")

############################################
# Memory Usage
############################################

MEM_PERCENT=$((MEM_USED*100/MEM_TOTAL))

############################################
# Load Status
############################################

LOAD_INT=$(echo "$LOAD" | cut -d. -f1)

if [ "$LOAD_INT" -le 1 ]
then
    LOAD_STATE="Light"
elif [ "$LOAD_INT" -le 3 ]
then
    LOAD_STATE="Normal"
else
    LOAD_STATE="High"
fi

############################################
# ===== STOP =====
# Part-3 starts from here
############################################
############################################
# Health Score
############################################

SCORE=100

[ "$CPU0" -ge 75 ] && SCORE=$((SCORE-10))
[ "$CPU1" -ge 75 ] && SCORE=$((SCORE-10))
[ "$CPU2" -ge 75 ] && SCORE=$((SCORE-10))
[ "$CPU3" -ge 75 ] && SCORE=$((SCORE-10))

[ "$MEM_PERCENT" -ge 90 ] && SCORE=$((SCORE-15))

[ "$LOAD_INT" -ge 4 ] && SCORE=$((SCORE-15))

[ "$WAN" = "Disconnected" ] && SCORE=$((SCORE-20))

############################################
# Overall Status
############################################

if [ "$SCORE" -ge 90 ]
then
    STATUS="EXCELLENT"
elif [ "$SCORE" -ge 75 ]
then
    STATUS="GOOD"
elif [ "$SCORE" -ge 60 ]
then
    STATUS="FAIR"
else
    STATUS="POOR"
fi
############################################
# Health Checks
############################################

[ "$LOAD_INT" -le 3 ] && CPU_CHECK="PASS" || CPU_CHECK="FAIL"

[ "$MEM_PERCENT" -lt 90 ] && MEM_CHECK="PASS" || MEM_CHECK="FAIL"

[ "$WAN" = "Connected" ] && NET_CHECK="PASS" || NET_CHECK="FAIL"

if [ "$CPU0" -lt 75 ] && \
   [ "$CPU1" -lt 75 ] && \
   [ "$CPU2" -lt 75 ] && \
   [ "$CPU3" -lt 75 ]
then
    TEMP_CHECK="PASS"
else
    TEMP_CHECK="FAIL"
fi
############################################
# Router Health Checks
############################################

if [ "$WIFI24" = "UP" ] && [ "$WIFI5" = "UP" ]
then
    WIFI_STATUS="Operational"
else
    WIFI_STATUS="Check Radios"
fi

############################################
# ===== STOP =====
# Part-4 starts from here
############################################
############################################
# Display
############################################

echo "Hardware"
line
printf "%-16s : %2d°C [%s]\n" "CPU Sensor 1" "$CPU0" "$CPU0_STATE"
printf "%-16s : %2d°C [%s]\n" "CPU Sensor 2" "$CPU1" "$CPU1_STATE"
printf "%-16s : %2d°C [%s]\n" "CPU Sensor 3" "$CPU2" "$CPU2_STATE"
printf "%-16s : %2d°C [%s]\n" "CPU Sensor 4" "$CPU3" "$CPU3_STATE"

echo
echo "Memory"
line
printf "%-16s : %d MB\n" "Total" "$MEM_TOTAL"
printf "%-16s : %d MB (%d%%)\n" "Used" "$MEM_USED" "$MEM_PERCENT"
printf "%-16s : %d MB\n" "Free" "$MEM_FREE"
printf "%-16s : %d MB\n" "Shared" "$MEM_SHARED"
printf "%-16s : %d MB\n" "Cached" "$MEM_CACHE"
printf "%-16s : %d MB\n" "Available" "$MEM_AVAIL"

echo
echo "Performance"
line
printf "%-16s : %d MHz\n" "CPU Frequency" "$CPU_FREQ"
printf "%-16s : %s\n" "CPU Load" "$LOAD"
printf "%-16s : %s\n" "Load Status" "$LOAD_STATE"
printf "%-16s : %s\n" "Processes" "$PROC"
printf "%-16s : %dd %dh %dm\n" "Uptime" "$DAY" "$HOUR" "$MIN"

echo
echo "Storage"
line
printf "%-16s : %s\n" "/opt" "$OPT"
printf "%-16s : %s\n" "/configs" "$CFG"
printf "%-16s : %s\n" "/logs" "$LOGS"
printf "%-16s : %s\n" "/backup" "$BACKUP"

echo
echo "Network"
line
printf "%-16s : %s\n" "WAN" "$WAN"
printf "%-16s : %s\n" "2.4 GHz Radio" "$WIFI24"
printf "%-16s : %s\n" "5 GHz Radio" "$WIFI5"
printf "%-16s : %d\n" "2.4 GHz Clients" "$CLIENT24"
printf "%-16s : %d\n" "5 GHz Clients" "$CLIENT5"
printf "%-16s : %d\n" "Total Clients" "$TOTAL_CLIENTS"
printf "%-16s : %s\n" "WiFi Status" "$WIFI_STATUS"

echo
echo "Overall"
line
printf "%-16s : %d / 100\n" "Health Score" "$SCORE"
printf "%-16s : %s\n" "Router Status" "$STATUS"

echo
printf "%-16s : %s\n" "Temperature" "$TEMP_CHECK"
printf "%-16s : %s\n" "Memory" "$MEM_CHECK"
printf "%-16s : %s\n" "CPU" "$CPU_CHECK"
printf "%-16s : %s\n" "Network" "$NET_CHECK"
line
root@AAP321NK:/opt/nbdt#
