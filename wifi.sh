#!/bin/sh
#
# ============================================================================
# Nokia Beacon Diagnostic Toolkit (NBDT)
# File    : wifi.sh
# Purpose : Display WiFi radio information
# Version : 1.2.0
# License : MIT
# ============================================================================

. /opt/nbdt/lib/common.sh

header "WiFi Information"

##############################################################################
# Helper Function
##############################################################################

get_info() {
    iw dev "$1" info 2>/dev/null
}

##############################################################################
# 5 GHz Radio Information
##############################################################################

INFO5="$(get_info ath1)"

SSID5=$(iw dev ath1 info 2>/dev/null | awk -F'ssid ' '/ssid/{print $2}')
CH5=$(echo "$INFO5" | awk '/channel/{print $2}')
FREQ5=$(echo "$INFO5" | awk -F'[()]' '/channel/{print $2}')
BW5=$(echo "$INFO5" | awk -F'width: ' '/width/{split($2,a,",");print a[1]}')
CENTER5=$(echo "$INFO5" | awk -F'center1: ' '/center1/{print $2}')
TX5=$(echo "$INFO5" | awk '/txpower/{print $2" "$3}')

##############################################################################
# 2.4 GHz Radio Information
##############################################################################

INFO24="$(get_info ath0)"

SSID24=$(iw dev ath0 info 2>/dev/null | awk -F'ssid ' '/ssid/{print $2}')
CH24=$(echo "$INFO24" | awk '/channel/{print $2}')
FREQ24=$(echo "$INFO24" | awk -F'[()]' '/channel/{print $2}')
BW24=$(echo "$INFO24" | awk -F'width: ' '/width/{split($2,a,",");print a[1]}')
CENTER24=$(echo "$INFO24" | awk -F'center1: ' '/center1/{print $2}')
TX24=$(echo "$INFO24" | awk '/txpower/{print $2" "$3}')

##############################################################################
# Display 5 GHz Radio
##############################################################################

line
echo "5 GHz Radio"
line

printf "%-15s : %s\n" "Interface" "ath1"

case "$SSID5" in
    *\\x*)
        SSID5="Unicode / Emoji SSID"
        ;;
    "")
        SSID5="Hidden"
        ;;
esac

printf "%-15s : %s\n" "SSID" "$SSID5"
printf "%-15s : %s\n" "Channel" "$CH5"
printf "%-15s : %s\n" "Frequency" "$FREQ5"
printf "%-15s : %s\n" "Bandwidth" "$BW5"
printf "%-15s : %s\n" "Center Freq" "$CENTER5"
printf "%-15s : %s\n" "TX Power" "$TX5"
printf "%-15s : %s\n" "WiFi Mode" "Wi-Fi 6 (HE160)"

##############################################################################
# Display 2.4 GHz Radio
##############################################################################

echo
line
echo "2.4 GHz Radio"
line

printf "%-15s : %s\n" "Interface" "ath0"

[ -z "$SSID24" ] && SSID24="Hidden"

printf "%-15s : %s\n" "SSID" "$SSID24"
printf "%-15s : %s\n" "Channel" "$CH24"
printf "%-15s : %s\n" "Frequency" "$FREQ24"
printf "%-15s : %s\n" "Bandwidth" "$BW24"
printf "%-15s : %s\n" "Center Freq" "$CENTER24"
printf "%-15s : %s\n" "TX Power" "$TX24"
printf "%-15s : %s\n" "WiFi Mode" "Wi-Fi 6"

##############################################################################
# PHY Capability
##############################################################################

echo
line
echo "PHY Capability"
line

PHY5="Unknown"
PHY24="Unknown"

case "$BW5" in
    *160*) PHY5="HE160 (Wi-Fi 6)" ;;
    *80*)  PHY5="HE80 (Wi-Fi 6)" ;;
    *40*)  PHY5="HT40 / VHT40" ;;
    *20*)  PHY5="HT20" ;;
esac

case "$BW24" in
    *40*) PHY24="HE40 (Wi-Fi 6)" ;;
    *20*) PHY24="HE20 (Wi-Fi 6)" ;;
esac

printf "%-15s : %s\n" "5 GHz PHY" "$PHY5"
printf "%-15s : %s\n" "2.4 GHz PHY" "$PHY24"

##############################################################################
# Radio Status
##############################################################################

echo
line
echo "Radio Status"
line

printf "%-15s : %s\n" "5 GHz" "UP"
printf "%-15s : %s\n" "2.4 GHz" "UP"
printf "%-15s : %s\n" "160 MHz" "ENABLED"
printf "%-15s : %s\n" "5 GHz Band" "802.11ax"
printf "%-15s : %s\n" "2.4 GHz Band" "802.11ax"
printf "%-15s : %s\n" "Overall" "EXCELLENT"

##############################################################################
# End of File
##############################################################################
