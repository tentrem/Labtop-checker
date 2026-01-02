#!/bin/bash

# =============================================================================
# MacBook Health Checker Script
# Script untuk mengecek kesehatan MacBook bekas sebelum membeli
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Separator
separator() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

header() {
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

clear
echo -e "${BOLD}${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         🍎 MacBook Health Checker - Panduan Bekas 🍎          ║"
echo "║                    v1.0 - January 2026                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

separator

# =============================================================================
# STEP 1: Check SSD Health
# =============================================================================
header "📦 STEP 1: Kesehatan SSD"

# Check if smartctl is installed
if ! command -v smartctl &> /dev/null; then
    error "smartmontools belum terinstall!"
    echo "   Install dengan: brew install smartmontools"
    SSD_CHECK=false
else
    echo ""
    echo -e "${BOLD}Mengambil data SMART dari SSD...${NC}"
    echo ""
    
    # Run smartctl and capture output
    SMART_OUTPUT=$(sudo smartctl -a disk0 2>/dev/null)
    
    if [ -z "$SMART_OUTPUT" ]; then
        error "Gagal membaca SMART data. Pastikan disk0 adalah SSD utama."
    else
        # Extract key metrics
        HEALTH=$(echo "$SMART_OUTPUT" | grep -i "SMART overall-health" | awk -F: '{print $2}' | xargs)
        PERCENTAGE_USED=$(echo "$SMART_OUTPUT" | grep -i "Percentage Used" | awk -F: '{print $2}' | xargs | tr -d '%')
        DATA_WRITTEN=$(echo "$SMART_OUTPUT" | grep -i "Data Units Written" | head -1)
        POWER_ON_HOURS=$(echo "$SMART_OUTPUT" | grep -i "Power On Hours" | awk -F: '{print $2}' | xargs | tr -d ',')
        UNSAFE_SHUTDOWNS=$(echo "$SMART_OUTPUT" | grep -i "Unsafe Shutdowns" | awk -F: '{print $2}' | xargs)
        MEDIA_ERRORS=$(echo "$SMART_OUTPUT" | grep -i "Media and Data Integrity Errors" | awk -F: '{print $2}' | xargs)
        TEMPERATURE=$(echo "$SMART_OUTPUT" | grep -i "Temperature:" | head -1 | grep -oE '[0-9]+' | head -1)
        AVAILABLE_SPARE=$(echo "$SMART_OUTPUT" | grep -i "Available Spare:" | head -1 | awk -F: '{print $2}' | xargs | tr -d '%')
        
        echo -e "${BOLD}📊 Hasil Analisis SSD:${NC}"
        echo ""
        
        # Health Status
        if [ "$HEALTH" == "PASSED" ]; then
            success "Overall Health: PASSED"
        else
            error "Overall Health: $HEALTH"
        fi
        
        # Percentage Used
        if [ -n "$PERCENTAGE_USED" ]; then
            if [ "$PERCENTAGE_USED" -lt 30 ]; then
                success "Percentage Used: ${PERCENTAGE_USED}% (Aman < 30%)"
            elif [ "$PERCENTAGE_USED" -lt 70 ]; then
                warning "Percentage Used: ${PERCENTAGE_USED}% (Waspada 30-70%)"
            else
                error "Percentage Used: ${PERCENTAGE_USED}% (Tinggi > 70%)"
            fi
        fi
        
        # Power On Hours
        if [ -n "$POWER_ON_HOURS" ]; then
            POH_NUM=$(echo "$POWER_ON_HOURS" | tr -d ',' | tr -d ' ')
            if [ "$POH_NUM" -lt 5000 ]; then
                success "Power On Hours: $POWER_ON_HOURS jam (Aman < 5000)"
            elif [ "$POH_NUM" -lt 10000 ]; then
                warning "Power On Hours: $POWER_ON_HOURS jam (Waspada 5000-10000)"
            else
                error "Power On Hours: $POWER_ON_HOURS jam (Tinggi > 10000)"
            fi
        fi
        
        # Unsafe Shutdowns
        if [ -n "$UNSAFE_SHUTDOWNS" ]; then
            US_NUM=$(echo "$UNSAFE_SHUTDOWNS" | tr -d ',' | tr -d ' ')
            if [ "$US_NUM" -lt 20 ]; then
                success "Unsafe Shutdowns: $UNSAFE_SHUTDOWNS (Aman < 20)"
            elif [ "$US_NUM" -lt 100 ]; then
                warning "Unsafe Shutdowns: $UNSAFE_SHUTDOWNS (Waspada 20-100)"
            else
                error "Unsafe Shutdowns: $UNSAFE_SHUTDOWNS (Tinggi > 100)"
            fi
        fi
        
        # Media Errors
        if [ -n "$MEDIA_ERRORS" ]; then
            ME_NUM=$(echo "$MEDIA_ERRORS" | tr -d ',' | tr -d ' ')
            if [ "$ME_NUM" -eq 0 ]; then
                success "Media Errors: 0 (Bagus!)"
            elif [ "$ME_NUM" -lt 10 ]; then
                warning "Media Errors: $MEDIA_ERRORS (Ada error)"
            else
                error "Media Errors: $MEDIA_ERRORS (Banyak error!)"
            fi
        fi
        
        # Temperature
        if [ -n "$TEMPERATURE" ]; then
            if [ "$TEMPERATURE" -lt 45 ]; then
                success "Temperature: ${TEMPERATURE}°C (Normal)"
            elif [ "$TEMPERATURE" -lt 55 ]; then
                warning "Temperature: ${TEMPERATURE}°C (Hangat)"
            else
                error "Temperature: ${TEMPERATURE}°C (Panas!)"
            fi
        fi
        
        # Data Written
        if [ -n "$DATA_WRITTEN" ]; then
            echo ""
            info "Data Written: $(echo "$DATA_WRITTEN" | awk -F: '{print $2}' | xargs)"
        fi
        
        # Red Flags Check
        echo ""
        echo -e "${BOLD}🚨 Cek Red Flags:${NC}"
        RED_FLAGS=0
        
        if [ "$PERCENTAGE_USED" == "0" ] && [ "$POWER_ON_HOURS" == "0" ]; then
            error "Semua nilai = 0! Kemungkinan data dimanipulasi"
            RED_FLAGS=$((RED_FLAGS + 1))
        fi
        
        if [ "$POH_NUM" == "0" ] 2>/dev/null; then
            warning "Power On Hours = 0 - Periksa kondisi fisik device"
            RED_FLAGS=$((RED_FLAGS + 1))
        fi
        
        if [ "$RED_FLAGS" -eq 0 ]; then
            success "Tidak ada red flags terdeteksi"
        fi
    fi
fi

separator

# =============================================================================
# STEP 2: Check Battery Health
# =============================================================================
header "🔋 STEP 2: Kesehatan Baterai"

echo ""
BATTERY_OUTPUT=$(system_profiler SPPowerDataType 2>/dev/null)

if [ -z "$BATTERY_OUTPUT" ]; then
    error "Gagal membaca data baterai"
else
    CYCLE_COUNT=$(echo "$BATTERY_OUTPUT" | grep -i "Cycle Count" | awk -F: '{print $2}' | xargs)
    CONDITION=$(echo "$BATTERY_OUTPUT" | grep -i "Condition" | awk -F: '{print $2}' | xargs)
    MAX_CAPACITY=$(echo "$BATTERY_OUTPUT" | grep -i "Maximum Capacity" | awk -F: '{print $2}' | xargs | tr -d '%')
    FULL_CHARGE=$(echo "$BATTERY_OUTPUT" | grep -i "Full Charge Capacity" | head -1 | awk -F: '{print $2}' | xargs)
    CHARGING=$(echo "$BATTERY_OUTPUT" | grep -i "Charging" | head -1 | awk -F: '{print $2}' | xargs)
    
    echo -e "${BOLD}📊 Hasil Analisis Baterai:${NC}"
    echo ""
    
    # Cycle Count
    if [ -n "$CYCLE_COUNT" ]; then
        CC_NUM=$(echo "$CYCLE_COUNT" | tr -d ',' | tr -d ' ')
        if [ "$CC_NUM" -lt 300 ]; then
            success "Cycle Count: $CYCLE_COUNT (Bagus < 300)"
        elif [ "$CC_NUM" -lt 800 ]; then
            warning "Cycle Count: $CYCLE_COUNT (Cukup 300-800)"
        else
            error "Cycle Count: $CYCLE_COUNT (Tinggi > 800)"
        fi
    fi
    
    # Maximum Capacity
    if [ -n "$MAX_CAPACITY" ]; then
        if [ "$MAX_CAPACITY" -gt 85 ]; then
            success "Maximum Capacity: ${MAX_CAPACITY}% (Bagus > 85%)"
        elif [ "$MAX_CAPACITY" -gt 70 ]; then
            warning "Maximum Capacity: ${MAX_CAPACITY}% (Cukup 70-85%)"
        else
            error "Maximum Capacity: ${MAX_CAPACITY}% (Rendah < 70%)"
        fi
    fi
    
    # Condition
    if [ -n "$CONDITION" ]; then
        if [ "$CONDITION" == "Normal" ]; then
            success "Condition: $CONDITION"
        else
            error "Condition: $CONDITION"
        fi
    fi
    
    # Additional Info
    if [ -n "$FULL_CHARGE" ]; then
        info "Full Charge Capacity: $FULL_CHARGE"
    fi
    
    if [ -n "$CHARGING" ]; then
        info "Status: $CHARGING"
    fi
fi

separator

# =============================================================================
# STEP 3: System Information
# =============================================================================
header "💻 STEP 3: Informasi Sistem"

echo ""
HARDWARE_OUTPUT=$(system_profiler SPHardwareDataType 2>/dev/null)

if [ -z "$HARDWARE_OUTPUT" ]; then
    error "Gagal membaca informasi hardware"
else
    MODEL_NAME=$(echo "$HARDWARE_OUTPUT" | grep -i "Model Name" | awk -F: '{print $2}' | xargs)
    MODEL_ID=$(echo "$HARDWARE_OUTPUT" | grep -i "Model Identifier" | awk -F: '{print $2}' | xargs)
    CHIP=$(echo "$HARDWARE_OUTPUT" | grep -i "Chip" | awk -F: '{print $2}' | xargs)
    MEMORY=$(echo "$HARDWARE_OUTPUT" | grep -i "Memory" | awk -F: '{print $2}' | xargs)
    SERIAL=$(echo "$HARDWARE_OUTPUT" | grep -i "Serial Number" | awk -F: '{print $2}' | xargs)
    MACOS=$(sw_vers -productVersion 2>/dev/null)
    
    echo -e "${BOLD}📊 Detail Hardware:${NC}"
    echo ""
    info "Model: $MODEL_NAME"
    info "Model Identifier: $MODEL_ID"
    info "Chip/Processor: $CHIP"
    
    # Check RAM
    if [ -n "$MEMORY" ]; then
        RAM_SIZE=$(echo "$MEMORY" | grep -oE '[0-9]+' | head -1)
        if [ "$RAM_SIZE" -ge 16 ]; then
            success "Memory: $MEMORY (Recommended ≥ 16GB)"
        else
            warning "Memory: $MEMORY (Kurang dari 16GB - tidak bisa upgrade!)"
        fi
    fi
    
    info "Serial Number: $SERIAL"
    info "macOS Version: $MACOS"
    
    echo ""
    echo -e "${YELLOW}💡 Verifikasi Serial Number di: https://checkcoverage.apple.com${NC}"
fi

separator

# =============================================================================
# STEP 4: Check MDM Profile
# =============================================================================
header "🔒 STEP 4: Cek MDM Profile"

echo ""
echo -e "${BOLD}Memeriksa MDM/Configuration Profiles...${NC}"
echo ""

PROFILES_OUTPUT=$(profiles list 2>&1)

if echo "$PROFILES_OUTPUT" | grep -qi "no profiles"; then
    success "Tidak ada MDM Profile terinstall"
    success "Device BUKAN milik perusahaan"
elif echo "$PROFILES_OUTPUT" | grep -qi "error"; then
    warning "Tidak dapat membaca profiles (mungkin tidak ada)"
else
    error "DITEMUKAN Profile terinstall!"
    echo ""
    echo "$PROFILES_OUTPUT"
    echo ""
    error "Device mungkin milik perusahaan - HINDARI!"
fi

separator

# =============================================================================
# STEP 5: Disk Information
# =============================================================================
header "💾 STEP 5: Informasi Disk"

echo ""
echo -e "${BOLD}📊 Daftar Disk:${NC}"
echo ""
diskutil list 2>/dev/null | head -30

echo ""
echo -e "${BOLD}📊 Info Disk Utama:${NC}"
echo ""
diskutil info disk0 2>/dev/null | grep -E "Device|Media Name|Solid State|Total Size|Device Block Size"

separator

# =============================================================================
# STEP 6: Memory & Swap Usage
# =============================================================================
header "🧠 STEP 6: Memory & Swap Usage"

echo ""
echo -e "${BOLD}📊 Memory Pressure:${NC}"
echo ""
memory_pressure 2>/dev/null | head -5

echo ""
echo -e "${BOLD}📊 Swap Usage:${NC}"
SWAP_INFO=$(sysctl vm.swapusage 2>/dev/null)
echo "$SWAP_INFO"

separator

# =============================================================================
# STEP 7: Check Kernel Panic History
# =============================================================================
header "💥 STEP 7: Kernel Panic History"

echo ""
echo -e "${BOLD}Memeriksa riwayat Kernel Panic...${NC}"
echo ""

PANIC_DIR="/Library/Logs/DiagnosticReports"
PANIC_COUNT=0
HANG_COUNT=0

# Check for panic files
if [ -d "$PANIC_DIR" ]; then
    PANIC_FILES=$(find "$PANIC_DIR" -name "*.panic" 2>/dev/null)
    if [ -n "$PANIC_FILES" ]; then
        PANIC_COUNT=$(echo "$PANIC_FILES" | wc -l | xargs)
    else
        PANIC_COUNT=0
    fi
    
    # Check for hang reports
    HANG_FILES=$(find "$PANIC_DIR" -name "*.hang" -o -name "*.spin" 2>/dev/null)
    if [ -n "$HANG_FILES" ]; then
        HANG_COUNT=$(echo "$HANG_FILES" | wc -l | xargs)
    else
        HANG_COUNT=0
    fi
fi

# Display results
if [ "$PANIC_COUNT" -eq 0 ] || [ -z "$PANIC_FILES" ]; then
    success "Tidak ada Kernel Panic ditemukan"
else
    error "Ditemukan $PANIC_COUNT file Kernel Panic!"
    echo ""
    echo -e "${YELLOW}File Panic terbaru:${NC}"
    ls -lt "$PANIC_DIR"/*.panic 2>/dev/null | head -5
    echo ""
    
    # Show date of most recent panic
    LATEST_PANIC=$(ls -t "$PANIC_DIR"/*.panic 2>/dev/null | head -1)
    if [ -n "$LATEST_PANIC" ]; then
        PANIC_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$LATEST_PANIC" 2>/dev/null)
        warning "Panic terakhir: $PANIC_DATE"
    fi
fi

# Check hang reports
if [ "$HANG_COUNT" -gt 0 ] && [ -n "$HANG_FILES" ]; then
    warning "Ditemukan $HANG_COUNT laporan Hang/Spin"
fi

# Check shutdown cause from NVRAM
echo ""
echo -e "${BOLD}📊 Shutdown Cause (dari NVRAM):${NC}"
SHUTDOWN_CAUSE=$(nvram shutdown-cause 2>/dev/null | awk '{print $2}')

if [ -n "$SHUTDOWN_CAUSE" ]; then
    case $SHUTDOWN_CAUSE in
        0)
            success "Shutdown Cause: 0 (Normal shutdown)"
            ;;
        3)
            success "Shutdown Cause: 3 (Hard shutdown via power button)"
            ;;
        5)
            success "Shutdown Cause: 5 (Normal shutdown)"
            ;;
        -3)
            warning "Shutdown Cause: -3 (Multiple bad shutdowns)"
            ;;
        -60|-61|-62)
            warning "Shutdown Cause: $SHUTDOWN_CAUSE (Bad file system)"
            ;;
        -74)
            error "Shutdown Cause: -74 (Battery failure)"
            ;;
        -75)
            error "Shutdown Cause: -75 (High temperature)"
            ;;
        -79)
            warning "Shutdown Cause: -79 (Incorrect current)"
            ;;
        -86)
            warning "Shutdown Cause: -86 (Proximity temperature too high)"
            ;;
        -95)
            error "Shutdown Cause: -95 (CPU temperature too high)"
            ;;
        -100)
            warning "Shutdown Cause: -100 (Power supply issue)"
            ;;
        -103)
            error "Shutdown Cause: -103 (Battery overcharge)"
            ;;
        -104)
            error "Shutdown Cause: -104 (Unknown battery issue)"
            ;;
        -112)
            warning "Shutdown Cause: -112 (Software-initiated)"
            ;;
        -128)
            info "Shutdown Cause: -128 (Unknown/unclean shutdown)"
            ;;
        *)
            info "Shutdown Cause: $SHUTDOWN_CAUSE (Kode tidak dikenal)"
            ;;
    esac
else
    info "Tidak dapat membaca shutdown cause"
fi

# Summary for kernel health
echo ""
echo -e "${BOLD}📊 Ringkasan Stabilitas Sistem:${NC}"
if [ "$PANIC_COUNT" -eq 0 ] || [ -z "$PANIC_FILES" ]; then
    if [ "$HANG_COUNT" -eq 0 ] || [ -z "$HANG_FILES" ]; then
        success "Sistem stabil - tidak ada crash history"
    else
        warning "Beberapa hang terdeteksi, tapi tidak ada kernel panic"
    fi
else
    if [ "$PANIC_COUNT" -lt 3 ]; then
        warning "Ada kernel panic ($PANIC_COUNT). Periksa penyebabnya."
    else
        error "Banyak kernel panic ($PANIC_COUNT)! Kemungkinan ada masalah hardware."
    fi
fi

separator

# =============================================================================
# STEP 8: Thermal Throttling History
# =============================================================================
header "🌡️ STEP 8: Thermal Throttling History"

echo ""
echo -e "${BOLD}Memeriksa riwayat Thermal Throttling (7 hari terakhir)...${NC}"
echo ""

# Check thermal events
THERMAL_EVENTS=$(log show --predicate 'eventMessage contains "thermal" OR eventMessage contains "throttl"' --last 7d 2>/dev/null | grep -i -E "thermal|throttl" | head -20)
THERMAL_COUNT=$(echo "$THERMAL_EVENTS" | grep -c "." 2>/dev/null || echo "0")

if [ "$THERMAL_COUNT" -eq 0 ] || [ -z "$THERMAL_EVENTS" ]; then
    success "Tidak ada thermal throttling terdeteksi dalam 7 hari terakhir"
else
    if [ "$THERMAL_COUNT" -lt 10 ]; then
        warning "Ditemukan $THERMAL_COUNT event thermal dalam 7 hari"
    else
        error "Banyak thermal events ($THERMAL_COUNT)! Kemungkinan masalah cooling."
    fi
    echo ""
    echo -e "${YELLOW}Sample thermal events:${NC}"
    echo "$THERMAL_EVENTS" | head -5
fi

# Check current thermal state using multiple methods
echo ""
echo -e "${BOLD}📊 CPU/SOC Temperature:${NC}"

# Method 1: Try ioreg (works on Apple Silicon without special permissions)
SOC_TEMP=$(ioreg -r -d1 -c AppleARMPowerDaemon 2>/dev/null | grep "Temperature" | head -1)

# Method 2: Try thermal state from ioreg
if [ -z "$SOC_TEMP" ]; then
    SOC_TEMP=$(ioreg -r -n AppleSMC 2>/dev/null | grep -E "Temperature|Temp" | head -3)
fi

# Method 3: Try using thermal monitor logs
if [ -z "$SOC_TEMP" ]; then
    THERMAL_STATE=$(log show --predicate 'subsystem == "com.apple.thermalmonitor"' --last 5m 2>/dev/null | grep -i "level" | tail -1)
    if [ -n "$THERMAL_STATE" ]; then
        info "Thermal state dari log: ditemukan"
    fi
fi

if [ -n "$SOC_TEMP" ]; then
    info "$SOC_TEMP"
else
    # Fallback: show thermal pressure
    THERMAL_PRESSURE=$(sysctl -n machdep.xcpm.cpu_thermal_level 2>/dev/null || echo "")
    if [ -n "$THERMAL_PRESSURE" ]; then
        if [ "$THERMAL_PRESSURE" -eq 0 ] 2>/dev/null; then
            success "CPU Thermal Level: $THERMAL_PRESSURE (Normal)"
        elif [ "$THERMAL_PRESSURE" -lt 50 ] 2>/dev/null; then
            warning "CPU Thermal Level: $THERMAL_PRESSURE (Warm)"
        else
            error "CPU Thermal Level: $THERMAL_PRESSURE (Hot!)"
        fi
    else
        # Last resort: check if any thermal warnings exist
        THERMAL_WARN=$(pmset -g therm 2>/dev/null)
        if [ -n "$THERMAL_WARN" ]; then
            info "Thermal info via pmset:"
            echo "$THERMAL_WARN"
        else
            info "Temperature sensor tidak tersedia via CLI (normal di Apple Silicon)"
            info "Gunakan 'About This Mac > System Report > Power' untuk detail"
        fi
    fi
fi

separator

# =============================================================================
# STEP 9: I/O Errors Check
# =============================================================================
header "💿 STEP 9: I/O Errors (Disk Health)"

echo ""
echo -e "${BOLD}Memeriksa I/O Errors dalam 7 hari terakhir...${NC}"
echo ""

IO_ERRORS=$(log show --predicate 'eventMessage contains "I/O error" OR eventMessage contains "disk error" OR eventMessage contains "read error" OR eventMessage contains "write error"' --last 7d 2>/dev/null | grep -i "error" | head -20)
IO_COUNT=$(echo "$IO_ERRORS" | grep -c "." 2>/dev/null || echo "0")

if [ "$IO_COUNT" -eq 0 ] || [ -z "$IO_ERRORS" ]; then
    success "Tidak ada I/O errors terdeteksi"
else
    error "Ditemukan $IO_COUNT I/O errors! Kemungkinan SSD bermasalah."
    echo ""
    echo -e "${YELLOW}Sample I/O errors:${NC}"
    echo "$IO_ERRORS" | head -5
fi

# Additional disk check
echo ""
echo -e "${BOLD}📊 Filesystem Status:${NC}"
FS_CHECK=$(diskutil verifyVolume / 2>&1 | tail -3)
if echo "$FS_CHECK" | grep -qi "appears to be OK"; then
    success "Filesystem appears to be OK"
else
    warning "Filesystem status: $FS_CHECK"
fi

separator

# =============================================================================
# STEP 10: Sleep/Wake Issues
# =============================================================================
header "😴 STEP 10: Sleep/Wake Issues"

echo ""
echo -e "${BOLD}Memeriksa Sleep/Wake history...${NC}"
echo ""

# Get sleep/wake log
SLEEP_LOG=$(pmset -g log 2>/dev/null | grep -i -E "sleep|wake|hibernate" | tail -20)

# Count wake failures
WAKE_FAILURES=$(pmset -g log 2>/dev/null | grep -i "failure\|fail\|dark wake" | wc -l | xargs)

if [ "$WAKE_FAILURES" -lt 5 ]; then
    success "Sleep/Wake berjalan normal"
else
    warning "Ditemukan $WAKE_FAILURES potential wake issues"
fi

# Show last few sleep/wake events
echo ""
echo -e "${BOLD}📊 Recent Sleep/Wake Events:${NC}"
echo "$SLEEP_LOG" | tail -10

# Check assertion that prevent sleep
echo ""
echo -e "${BOLD}📊 Current Sleep Assertions:${NC}"
ASSERTIONS=$(pmset -g assertions 2>/dev/null | grep -E "PreventUserIdleSystemSleep|PreventSystemSleep" | head -5)
if [ -n "$ASSERTIONS" ]; then
    info "$ASSERTIONS"
else
    success "Tidak ada assertion yang mencegah sleep"
fi

separator

# =============================================================================
# STEP 11: First Boot Date (Estimasi Umur)
# =============================================================================
header "📅 STEP 11: Estimasi Umur Sistem"

echo ""
echo -e "${BOLD}Mencari tanggal first boot/install...${NC}"
echo ""

# Check AppleSetupDone file (created on first boot)
if [ -f "/var/db/.AppleSetupDone" ]; then
    FIRST_BOOT=$(stat -f "%Sm" -t "%Y-%m-%d" /var/db/.AppleSetupDone 2>/dev/null)
    info "macOS pertama kali di-setup: $FIRST_BOOT"
    
    # Calculate days since first boot
    FIRST_BOOT_SEC=$(date -j -f "%Y-%m-%d" "$FIRST_BOOT" "+%s" 2>/dev/null)
    NOW_SEC=$(date "+%s")
    DAYS_OLD=$(( (NOW_SEC - FIRST_BOOT_SEC) / 86400 ))
    
    if [ "$DAYS_OLD" -lt 365 ]; then
        success "Instalasi macOS: ~$DAYS_OLD hari ($((DAYS_OLD/30)) bulan)"
    elif [ "$DAYS_OLD" -lt 730 ]; then
        info "Instalasi macOS: ~$((DAYS_OLD/365)) tahun $((DAYS_OLD%365/30)) bulan"
    else
        warning "Instalasi macOS: ~$((DAYS_OLD/365)) tahun (cukup lama)"
    fi
else
    warning "Tidak dapat menentukan first boot date"
fi

# Check install.log for more info
INSTALL_DATE=$(ls -la /var/log/install.log 2>/dev/null | awk '{print $6, $7, $8}')
if [ -n "$INSTALL_DATE" ]; then
    info "Install log modified: $INSTALL_DATE"
fi

# Check /private/var/db/receipts for oldest package
echo ""
echo -e "${BOLD}📊 Oldest System Package:${NC}"
OLDEST_PKG=$(ls -lt /var/db/receipts/*.plist 2>/dev/null | tail -1)
if [ -n "$OLDEST_PKG" ]; then
    info "$(echo $OLDEST_PKG | awk '{print $6, $7, $8, $9}')"
fi

separator

# =============================================================================
# STEP 12: Security Status
# =============================================================================
header "🔐 STEP 12: Security Status"

echo ""
echo -e "${BOLD}Memeriksa status keamanan...${NC}"
echo ""

# FileVault Status
FILEVAULT=$(fdesetup status 2>/dev/null)
if echo "$FILEVAULT" | grep -qi "on"; then
    success "FileVault: Enabled (Disk terenkripsi)"
else
    info "FileVault: Disabled"
fi

# SIP Status
SIP_STATUS=$(csrutil status 2>/dev/null)
if echo "$SIP_STATUS" | grep -qi "enabled"; then
    success "System Integrity Protection: Enabled"
else
    warning "System Integrity Protection: Disabled (tidak normal!)"
fi

# Gatekeeper Status
GATEKEEPER=$(spctl --status 2>/dev/null)
if echo "$GATEKEEPER" | grep -qi "enabled"; then
    success "Gatekeeper: Enabled"
else
    warning "Gatekeeper: Disabled"
fi

# Firewall Status
FIREWALL=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
if echo "$FIREWALL" | grep -qi "enabled"; then
    success "Firewall: Enabled"
else
    info "Firewall: Disabled"
fi

# Check for firmware password
echo ""
echo -e "${BOLD}📊 Firmware Password:${NC}"
FW_PASS=$(sudo firmwarepasswd -check 2>/dev/null)
if echo "$FW_PASS" | grep -qi "No"; then
    success "Firmware Password: Not set"
elif echo "$FW_PASS" | grep -qi "Yes"; then
    warning "Firmware Password: SET (minta seller untuk disable!)"
else
    info "Tidak dapat memeriksa firmware password"
fi

separator

# =============================================================================
# STEP 13: App Crash History
# =============================================================================
header "💀 STEP 13: App Crash History"

echo ""
echo -e "${BOLD}Memeriksa riwayat crash aplikasi...${NC}"
echo ""

CRASH_DIR="/Library/Logs/DiagnosticReports"
USER_CRASH_DIR="$HOME/Library/Logs/DiagnosticReports"

# Count crash files
SYS_CRASHES=$(find "$CRASH_DIR" -name "*.crash" -mtime -30 2>/dev/null | wc -l | xargs)
USER_CRASHES=$(find "$USER_CRASH_DIR" -name "*.crash" -mtime -30 2>/dev/null | wc -l | xargs)
TOTAL_CRASHES=$((SYS_CRASHES + USER_CRASHES))

if [ "$TOTAL_CRASHES" -eq 0 ]; then
    success "Tidak ada app crash dalam 30 hari terakhir"
elif [ "$TOTAL_CRASHES" -lt 10 ]; then
    info "Ditemukan $TOTAL_CRASHES app crash dalam 30 hari (normal)"
else
    warning "Ditemukan $TOTAL_CRASHES app crash dalam 30 hari"
fi

# Show most crashed apps
echo ""
echo -e "${BOLD}📊 Apps with Most Crashes:${NC}"
CRASH_APPS=$(find "$CRASH_DIR" "$USER_CRASH_DIR" -name "*.crash" -mtime -30 2>/dev/null | xargs -I {} basename {} | sed 's/_.*//g' | sort | uniq -c | sort -rn | head -5)
if [ -n "$CRASH_APPS" ]; then
    echo "$CRASH_APPS"
else
    success "Tidak ada app crash terdeteksi"
fi

# Check for GPU crashes specifically
GPU_CRASHES=$(find "$CRASH_DIR" "$USER_CRASH_DIR" -name "*GPU*" -o -name "*WindowServer*" -mtime -30 2>/dev/null | wc -l | xargs)
if [ "$GPU_CRASHES" -gt 0 ]; then
    error "Ditemukan $GPU_CRASHES GPU-related crashes! Kemungkinan masalah graphics."
fi

separator

# =============================================================================
# STEP 14: Wi-Fi & Bluetooth Diagnostics
# =============================================================================
header "📶 STEP 14: Wi-Fi & Bluetooth Diagnostics"

echo ""
echo -e "${BOLD}Memeriksa Wi-Fi...${NC}"
echo ""

# Wi-Fi info
WIFI_INFO=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null)
WIFI_SSID=$(echo "$WIFI_INFO" | grep " SSID" | awk -F: '{print $2}' | xargs)
WIFI_RSSI=$(echo "$WIFI_INFO" | grep "agrCtlRSSI" | awk -F: '{print $2}' | xargs)
WIFI_NOISE=$(echo "$WIFI_INFO" | grep "agrCtlNoise" | awk -F: '{print $2}' | xargs)

if [ -n "$WIFI_SSID" ]; then
    success "Wi-Fi Connected: $WIFI_SSID"
    
    # Check signal quality
    if [ -n "$WIFI_RSSI" ]; then
        RSSI_VAL=$(echo "$WIFI_RSSI" | tr -d '-')
        if [ "$RSSI_VAL" -lt 50 ]; then
            success "Signal Strength: Excellent (RSSI: $WIFI_RSSI dBm)"
        elif [ "$RSSI_VAL" -lt 60 ]; then
            success "Signal Strength: Good (RSSI: $WIFI_RSSI dBm)"
        elif [ "$RSSI_VAL" -lt 70 ]; then
            warning "Signal Strength: Fair (RSSI: $WIFI_RSSI dBm)"
        else
            error "Signal Strength: Weak (RSSI: $WIFI_RSSI dBm)"
        fi
    fi
else
    warning "Wi-Fi tidak terhubung"
fi

# Check Bluetooth
echo ""
echo -e "${BOLD}Memeriksa Bluetooth...${NC}"
echo ""

BT_STATUS=$(system_profiler SPBluetoothDataType 2>/dev/null | head -20)
BT_STATE=$(echo "$BT_STATUS" | grep "State" | awk -F: '{print $2}' | xargs)
BT_DEVICES=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -c "Address:" || echo "0")

if echo "$BT_STATE" | grep -qi "on"; then
    success "Bluetooth: On"
else
    info "Bluetooth: Off atau tidak tersedia"
fi

info "Connected Bluetooth Devices: $BT_DEVICES"

# Check for Bluetooth errors in log
BT_ERRORS=$(log show --predicate 'subsystem == "com.apple.bluetooth"' --last 1h 2>/dev/null | grep -i "error\|fail" | wc -l | xargs)
if [ "$BT_ERRORS" -gt 10 ]; then
    warning "Ditemukan $BT_ERRORS Bluetooth errors dalam 1 jam terakhir"
else
    success "Bluetooth errors dalam 1 jam: $BT_ERRORS (normal)"
fi

separator

# =============================================================================
# SUMMARY
# =============================================================================
header "📋 RINGKASAN"

echo ""
echo -e "${BOLD}Checklist yang perlu diverifikasi manual:${NC}"
echo ""
echo "[ ] Serial number match (device, box, Apple website)"
echo "[ ] Activation Lock = OFF"
echo "[ ] Find My Mac = OFF"
echo "[ ] Layar OK (no dead pixel, stain)"
echo "[ ] Keyboard OK (semua tombol berfungsi)"
echo "[ ] Trackpad OK (Force Touch berfungsi)"
echo "[ ] Speaker OK (kiri & kanan)"
echo "[ ] Webcam OK"
echo "[ ] Port USB-C OK"
echo "[ ] WiFi & Bluetooth OK"
echo "[ ] Body OK (no dent, crack)"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}       ✅ Script selesai! Review hasil di atas dengan teliti.${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
