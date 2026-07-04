#!/bin/sh
#
# ============================================================================
# Nokia Beacon Diagnostic Toolkit (NBDT)
# File    : clients.sh
# Purpose : Display connected WiFi clients
# Version : 1.3.0
# License : MIT
# ============================================================================

. /opt/nbdt/lib/common.sh

header "Connected Clients"

##############################################################################
# Collect Live Data
##############################################################################

DATA24="$(wlanconfig ath0 list 2>/dev/null)"
DATA5="$(wlanconfig ath1 list 2>/dev/null)"

##############################################################################
# RSSI Quality
##############################################################################

signal_quality()
{
    RSSI="$1"

    if [ "$RSSI" -ge -50 ]
    then
        echo "Excellent"

    elif [ "$RSSI" -ge -60 ]
    then
        echo "Good"

    elif [ "$RSSI" -ge -70 ]
    then
        echo "Fair"

    else
        echo "Weak"
    fi
}
##############################################################################
# Count Connected Clients
##############################################################################

COUNT24=$(echo "$DATA24" | grep '^..:..:..:..:..:..' | wc -l)
COUNT5=$(echo "$DATA5" | grep '^..:..:..:..:..:..' | wc -l)

TOTAL=$((COUNT24 + COUNT5))
##############################################################################
# RSSI Statistics
##############################################################################

RSSI_LIST=$(echo "$DATA24
$DATA5" | awk '/^..:..:..:..:..:../ {print $6}')

if [ -n "$RSSI_LIST" ]
then
    BEST=$(echo "$RSSI_LIST" | sort -nr | head -1)
    WORST=$(echo "$RSSI_LIST" | sort -n | head -1)
    AVG=$(echo "$RSSI_LIST" | awk '{sum+=$1} END {printf "%.0f", sum/NR}')
else
    BEST=0
    WORST=0
    AVG=0
fi

##############################################################################
# Display
##############################################################################

line
echo "Summary"
line

printf "%-18s : %d\n" "Total Clients" "$TOTAL"
printf "%-18s : %d\n" "5 GHz Clients" "$COUNT5"
printf "%-18s : %d\n" "2.4 GHz Clients" "$COUNT24"
printf "%-18s : %d dBm\n" "Average RSSI" "$AVG"
printf "%-18s : %d dBm\n" "Best Signal" "$BEST"
printf "%-18s : %d dBm\n" "Weakest Signal" "$WORST"
line
##############################################################################
# 5 GHz Clients
##############################################################################
##############################################################################
# 5 GHz Parser Engine
##############################################################################
echo
line
echo "5 GHz Raw Data"
line
echo "$DATA5"

echo
line
echo "2.4 GHz Raw Data"
line
echo "$DATA24"
echo
line
echo "5 GHz Clients"
line

CLIENT_NO=0

MAC=""
TXRATE=""
RXRATE=""
RSSI=""
ASSOC=""
SNR=""
HT=""
VHT=""
MLO=""
PHYMODE=""

while IFS= read -r LINE
do

    case "$LINE" in

        ??\:??\:??\:??\:??\:??*)

            CLIENT_NO=$((CLIENT_NO+1))

            MAC=$(echo "$LINE" | awk '{print $1}')
            TXRATE=$(echo "$LINE" | awk '{print $4}')
            RXRATE=$(echo "$LINE" | awk '{print $5}')
            RSSI=$(echo "$LINE" | awk '{print $6}')

            ASSOC=$(echo "$LINE" | awk '{print $(NF-6)}')
            PHYMODE=$(echo "$LINE" | awk '{print $(NF-3)}')

            RXNSS=$(echo "$LINE" | awk '{print $(NF-2)}')
            TXNSS=$(echo "$LINE" | awk '{print $(NF-1)}')

            PSMODE=$(echo "$LINE" | awk '{print $NF}')

            ;;

        *"HT Capability"* )

            HT=$(echo "$LINE" | cut -d':' -f2 | xargs)
            ;;

        *"VHT Capability"* )

            echo "DEBUG: [$LINE]"

    VHT=$(echo "$LINE" | cut -d':' -f2 | xargs)

    echo "DEBUG VHT=[$VHT]"
            ;;

        *"SNR"* )

            SNR=$(echo "$LINE" | cut -d': ' -f2 | xargs)
            ;;

        *"MLO"* )

            MLO=$(echo "$LINE" | cut -d': ' -f2 | xargs)
            ;;

        "")

            if [ -n "$MAC" ]
            then

                echo
                echo "Client #$CLIENT_NO"

                printf "%-18s : %s\n" "MAC Address" "$MAC"

                printf "%-18s : %s\n" "Association" "$ASSOC"

                printf "%-18s : %s dBm\n" "RSSI" "$RSSI"

                printf "%-18s : %s dB\n" "SNR" "$SNR"

                printf "%-18s : %s\n" "TX Rate" "$TXRATE"

                printf "%-18s : %s\n" "RX Rate" "$RXRATE"

                printf "%-18s : %s\n" "PHY Mode" "$PHYMODE"

                printf "%-18s : %sx%s\n" "MIMO" "$RXNSS" "$TXNSS"

                printf "%-18s : %s\n" "HT Capability" "$HT"

                printf "%-18s : %s\n" "VHT Capability" "$VHT"

                printf "%-18s : %s\n" "MLO" "$MLO"

                if [ "$PSMODE" = "1" ]
                then
                    printf "%-18s : Enabled\n" "Power Save"
                else
                    printf "%-18s : Disabled\n" "Power Save"
                fi

             # Reset variables for next client
             MAC=""
             TXRATE=""
             RXRATE=""
             RSSI=""
             ASSOC=""
             SNR=""
             HT=""
             VHT=""
             MLO=""
                PHYMODE=""
              RXNSS=""
                TXNSS=""
                PSMODE=""
           fi
          ;;

    esac

done <<EOF
$DATA5
EOF

##############################################################################
# Flush Last Client
##############################################################################

if [ -n "$MAC" ]
then

    echo
    echo "Client #$CLIENT_NO"

    printf "%-18s : %s\n" "MAC Address" "$MAC"
    printf "%-18s : %s\n" "Association" "$ASSOC"
    printf "%-18s : %s dBm\n" "RSSI" "$RSSI"
    printf "%-18s : %s dB\n" "SNR" "$SNR"
    printf "%-18s : %s\n" "TX Rate" "$TXRATE"
    printf "%-18s : %s\n" "RX Rate" "$RXRATE"
    printf "%-18s : %s\n" "PHY Mode" "$PHYMODE"
    printf "%-18s : %sx%s\n" "MIMO" "$RXNSS" "$TXNSS"
    printf "%-18s : %s\n" "HT Capability" "$HT"
    printf "%-18s : %s\n" "VHT Capability" "$VHT"
    printf "%-18s : %s\n" "MLO" "$MLO"

    if [ "$PSMODE" = "1" ]
    then
        printf "%-18s : Enabled\n" "Power Save"
    else
        printf "%-18s : Disabled\n" "Power Save"
    fi

fi
