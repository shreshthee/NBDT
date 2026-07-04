#!/bin/sh
#
# ============================================================================
# Nokia Beacon Diagnostic Toolkit (NBDT)
# File    : about.sh
# Purpose : Display toolkit and router information
# Version : 1.2.0
# License : MIT
# ============================================================================

. /opt/nbdt/lib/common.sh

header "About"

##############################################################################
# Toolkit Information
##############################################################################

line
echo "Toolkit"
line

printf "%-13s : %s\n" "Name" "Nokia Beacon Diagnostic Toolkit"
printf "%-13s : %s\n" "Version" "$VERSION"
printf "%-13s : %s\n" "Codename" "Foundation"
printf "%-13s : %s\n" "Platform" "BusyBox ash"

##############################################################################
# Router Information
##############################################################################

echo
line
echo "Router"
line

MODEL=$(cat /tmp/sysinfo/model 2>/dev/null)
[ -z "$MODEL" ] && MODEL="AAP321NK"

SOC=$(tr '\0' '\n' < /proc/device-tree/model 2>/dev/null)

printf "%-13s : %s\n" "Product" "Nokia Beacon 3.2"
printf "%-13s : %s\n" "Model" "$MODEL"
printf "%-13s : %s\n" "SoC" "$SOC"

##############################################################################
# System Information
##############################################################################

echo
line
echo "System"
line

HOST=$(hostname 2>/dev/null)
[ -z "$HOST" ] && HOST="AAP321NK"

printf "%-13s : %s\n" "Hostname" "$HOST"
printf "%-13s : %s\n" "Kernel" "$(uname -r)"
printf "%-13s : %s\n" "Architecture" "$(uname -m)"

##############################################################################
# Installation
##############################################################################

echo
line
echo "Storage"
line

FREE=$(df -h /opt | awk 'NR==2 {print $4}')

printf "%-13s : %s\n" "Install" "/opt/nbdt"
printf "%-13s : %s free\n" "Available" "$FREE"

##############################################################################
# Toolkit Statistics
##############################################################################

echo
line
echo "Toolkit Statistics"
line

SIZE=$(du -sh /opt/nbdt 2>/dev/null | awk '{print $1}')
FILES=$(find /opt/nbdt -type f | wc -l)

printf "%-13s : %s\n" "Toolkit Size" "$SIZE"
printf "%-13s : %s\n" "Files" "$FILES"

##############################################################################
# Features
##############################################################################

echo
line
echo "Features"
line

echo "✓ Persistent Storage"
echo "✓ BusyBox Compatible"
echo "✓ Lightweight"
echo "✓ Read Only"
echo "✓ No Background Process"
echo "✓ No Daemon"
echo "✓ No Cron Jobs"

##############################################################################
# Project Information
##############################################################################

echo
line
echo "Project"
line

printf "%-13s : %s\n" "Author" "Shailesh Kumar"
printf "%-13s : %s\n" "Release" "v1.2 Stable"
printf "%-13s : %s\n" "License" "MIT"
printf "%-13s : %s\n" "Repository" "https://github.com/shreshthee/NBDT"

##############################################################################
# Acknowledgements
##############################################################################

echo
line
echo "Acknowledgements"
line

echo "• Project design, development and maintenance:"
echo "  Shailesh Kumar"

echo
echo "• Development assistance:"
echo "  OpenAI ChatGPT"
