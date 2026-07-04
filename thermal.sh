#!/bin/sh
#
# ============================================================================
# Nokia Beacon Diagnostic Toolkit (NBDT)
# File    : thermal.sh
# Purpose : Display CPU and WiFi thermal information
# Version : 1.2.0
# License : MIT
# ============================================================================

. /opt/nbdt/lib/common.sh

header "Thermal Information"

##############################################################################
# Read CPU Thermal Sensors
##############################################################################

CPU1=$(($(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null) / 1000))
CPU2=$(($(cat /sys/class/thermal/thermal_zone1/temp 2>/dev/null) / 1000))
CPU3=$(($(cat /sys/class/thermal/thermal_zone2/temp 2>/dev/null) / 1000))
CPU4=$(($(cat /sys/class/thermal/thermal_zone3/temp 2>/dev/null) / 1000))

##############################################################################
# Read WiFi Radio Temperatures
##############################################################################

WIFI24=$(cat /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
WIFI5=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)

[ -n "$WIFI24" ] && WIFI24=$((WIFI24 / 1000))
[ -n "$WIFI5" ] && WIFI5=$((WIFI5 / 1000))

##############################################################################
# Calculate Thermal Statistics
##############################################################################

MAX=$CPU1
[ "$CPU2" -gt "$MAX" ] && MAX=$CPU2
[ "$CPU3" -gt "$MAX" ] && MAX=$CPU3
[ "$CPU4" -gt "$MAX" ] && MAX=$CPU4

AVG=$(((CPU1 + CPU2 + CPU3 + CPU4) / 4))

##############################################################################
# Overall Thermal Status
##############################################################################

if [ "$MAX" -lt 65 ]; then
    STATUS="NORMAL"
elif [ "$MAX" -lt 75 ]; then
    STATUS="WARM"
else
    STATUS="HOT"
fi

##############################################################################
# Sensor Status Helper
##############################################################################

sensor_state() {
    if [ "$1" -lt 65 ]; then
        echo "OK"
    elif [ "$1" -lt 75 ]; then
        echo "WARM"
    else
        echo "HOT"
    fi
}

##############################################################################
# CPU Sensors
##############################################################################

line
echo "CPU Sensors"
line

printf "%-15s : %2d°C [%s]\n" "Sensor 1" "$CPU1" "$(sensor_state "$CPU1")"
printf "%-15s : %2d°C [%s]\n" "Sensor 2" "$CPU2" "$(sensor_state "$CPU2")"
printf "%-15s : %2d°C [%s]\n" "Sensor 3" "$CPU3" "$(sensor_state "$CPU3")"
printf "%-15s : %2d°C [%s]\n" "Sensor 4" "$CPU4" "$(sensor_state "$CPU4")"

##############################################################################
# WiFi Radio Temperatures
##############################################################################

echo
line
echo "WiFi Radios"
line

printf "%-15s : %2d°C\n" "2.4 GHz" "$WIFI24"
printf "%-15s : %2d°C\n" "5 GHz" "$WIFI5"

##############################################################################
# Thermal Summary
##############################################################################

echo
line
echo "Thermal Summary"
line

printf "%-15s : %2d°C\n" "Highest Temp" "$MAX"
printf "%-15s : %2d°C\n" "Average Temp" "$AVG"
printf "%-15s : %s\n" "Status" "$STATUS"

##############################################################################
# End of File
##############################################################################
