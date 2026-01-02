# 📋 Panduan Lengkap Membeli MacBook Bekas

*Terakhir diperbarui: 2 Januari 2026*

---

## 📦 Persiapan: Install Tools yang Diperlukan

### 1. Install Homebrew (Package Manager untuk macOS)

Jika belum ada Homebrew, install dulu:

```bash
# Cek apakah Homebrew sudah terinstall
which brew

# Jika belum ada, install dengan command berikut:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ikuti instruksi di layar untuk menambahkan ke PATH
# Biasanya perlu jalankan:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Install smartmontools (SSD Health Checker)

```bash
# Install smartmontools
brew install smartmontools

# Verifikasi instalasi
smartctl --version
```

### 3. Tools Tambahan (Opsional)

```bash
# Install neofetch untuk info sistem
brew install neofetch

# Install htop untuk monitoring resource
brew install htop
```

---

## 🔍 Checklist Sebelum Membeli

### ✅ Dokumen yang Harus Diminta

- [ ] Invoice/struk pembelian original
- [ ] Box original (meningkatkan resale value)
- [ ] Charger original MagSafe/USB-C
- [ ] Informasi sisa garansi Apple
- [ ] AppleCare+ (jika ada)

### ✅ Spesifikasi Minimum yang Disarankan

| Komponen | Minimum | Ideal | Alasan |
|----------|---------|-------|--------|
| **RAM** | 16 GB | 16-32 GB | Tidak bisa upgrade! |
| **SSD** | 256 GB | 512 GB+ | Lebih besar = umur lebih panjang |
| **Chip** | M1 | M1 Pro/M2+ | Future-proof |
| **Battery Cycle** | < 500 | < 300 | Kapasitas masih bagus |

> ⚠️ **PENTING:** RAM pada M1/M2 Mac **TIDAK BISA DI-UPGRADE**! Pilih yang sudah besar dari awal.

---

## 🔧 Step-by-Step Pengecekan

### Step 1: Cek Kesehatan SSD (PALING PENTING!)

#### Jalankan command berikut

```bash
# Full SMART data
sudo smartctl -a disk0

# Atau ringkasan saja
sudo smartctl -a disk0 | grep -E "Percentage|Written|Temperature|Health|Power On|Unsafe"
```

#### Interpretasi Hasil

| Metrik | ✅ Aman | ⚠️ Waspada | ❌ Hindari |
|--------|---------|------------|-----------|
| **Percentage Used** | < 30% | 30-70% | > 70% |
| **Data Units Written** | < 50 TB | 50-100 TB | > 100 TB |
| **Power-On Hours** | < 5000 jam | 5000-10000 jam | > 15000 jam |
| **Media Errors** | 0 | > 0 | > 10 |
| **Unsafe Shutdowns** | < 20 | 20-100 | > 100 |
| **Temperature** | < 45°C | 45-55°C | > 60°C |

#### 🚨 Red Flags (Kemungkinan Data Dimanipulasi)

- ❌ Semua nilai = 0 (terlalu sempurna)
- ❌ Power-On Hours = 0 tapi fisik sudah lecet/bekas
- ❌ TBW = 0 persis
- ❌ Nilai tidak konsisten dengan umur device

#### Contoh Output yang Sehat

```
SMART overall-health self-assessment test result: PASSED
Temperature:                        35 Celsius
Available Spare:                    100%
Percentage Used:                    2%
Data Units Written:                 34,129,142 [17.4 TB]
Power On Hours:                     577
Unsafe Shutdowns:                   6
Media and Data Integrity Errors:    0
```

---

### Step 2: Cek Kesehatan Baterai

```bash
# Cek battery health
system_profiler SPPowerDataType | grep -E "Cycle Count|Condition|Maximum Capacity|Full Charge"
```

#### Interpretasi

| Metrik | ✅ Bagus | ⚠️ Cukup | ❌ Buruk |
|--------|----------|----------|----------|
| **Cycle Count** | < 300 | 300-800 | > 800 |
| **Maximum Capacity** | > 85% | 70-85% | < 70% |
| **Condition** | Normal | - | Service Recommended |

#### Contoh Output yang Sehat

```
Cycle Count: 250
Condition: Normal
Maximum Capacity: 92%
```

---

### Step 3: Cek Informasi Sistem

```bash
# Info sistem lengkap
system_profiler SPHardwareDataType

# Atau gunakan neofetch (jika terinstall)
neofetch
```

**Yang perlu dicatat:**

- Model Identifier
- Serial Number
- RAM (Memory)
- Chip/Processor

---

### Step 4: Verifikasi Serial Number

1. **Catat Serial Number** dari About This Mac
2. **Cek di Apple:** [checkcoverage.apple.com](https://checkcoverage.apple.com)
3. **Pastikan match** dengan stiker di bawah MacBook dan box

**Verifikasi:**

- [ ] Serial number valid di website Apple
- [ ] Match dengan fisik device
- [ ] Match dengan box (jika ada)

---

### Step 5: Cek Activation Lock & iCloud

**WAJIB dilakukan sebelum bayar!**

1. Minta seller **logout dari iCloud** di depan Anda:
   - System Settings > Apple ID > Sign Out

2. Pastikan **Find My Mac = OFF**:
   - System Settings > Apple ID > iCloud > Find My Mac

3. Cek **tidak ada MDM Profile** (device perusahaan):

   ```bash
   # Cek profiles
   profiles list
   ```

   Atau: System Settings > Privacy & Security > Profiles

   > ⚠️ Jika ada MDM Profile, device mungkin milik perusahaan - HINDARI!

---

### Step 6: Cek Fisik Device

#### Layar

- [ ] Tidak ada dead pixel (test dengan gambar putih polos)
- [ ] Tidak ada burn-in (test dengan gambar hitam)
- [ ] Tidak ada stain/noda
- [ ] Coating tidak terkelupas
- [ ] Brightness merata

#### Keyboard

- [ ] Semua tombol berfungsi
- [ ] Tidak ada tombol yang macet
- [ ] Backlight berfungsi (jika ada)
- [ ] Touch Bar berfungsi (jika ada)

#### Trackpad

- [ ] Force Touch berfungsi
- [ ] Multi-gesture berfungsi
- [ ] Tidak ada dead zone

#### Port & Konektivitas

- [ ] Semua USB-C port berfungsi
- [ ] Headphone jack berfungsi
- [ ] MagSafe charging berfungsi (jika ada)
- [ ] WiFi konek normal
- [ ] Bluetooth berfungsi

#### Speaker & Audio

- [ ] Speaker kiri dan kanan berfungsi
- [ ] Tidak ada suara crackling
- [ ] Microphone berfungsi (test dengan Voice Memo)

#### Kamera

- [ ] Webcam berfungsi
- [ ] Kualitas gambar bagus

#### Body

- [ ] Tidak ada dent/penyok
- [ ] Tidak ada crack
- [ ] Hinge tidak longgar
- [ ] Rubber feet masih ada

---

### Step 7: Test Performance

```bash
# Install Geekbench (benchmark tool)
# Download dari: https://www.geekbench.com/

# Atau gunakan command line benchmark sederhana
time dd if=/dev/zero of=/tmp/testfile bs=1m count=1024
rm /tmp/testfile
```

**Bandingkan hasil dengan:**

- [Geekbench Browser](https://browser.geekbench.com/mac-benchmarks)
- Score jauh lebih rendah = kemungkinan ada throttling/masalah

---

## ⚠️ Jangan Beli Kalau

| Kondisi | Alasan |
|---------|--------|
| Seller menolak kasih akses SMART data | Mungkin menyembunyikan sesuatu |
| Activation Lock masih aktif | Tidak bisa digunakan |
| Ada MDM Profile | Device perusahaan, bisa di-lock remote |
| SSD Percentage Used > 50% | Umur SSD tinggal separuh |
| Battery < 70% capacity | Perlu ganti baterai (~$200+) |
| Harga terlalu murah | Too good to be true |
| Tidak ada invoice | Kemungkinan curian |
| Serial number tidak match | Palsu atau frankenMac |

---

## 💡 Tips Tambahan

### Negosiasi Harga

Gunakan kondisi berikut untuk minta diskon:

- Battery cycle tinggi (> 300)
- SSD usage tinggi (> 20%)
- Garansi sudah habis
- Ada scratch/dent minor
- Tidak ada box/kelengkapan

### Rekomendasi Model - Range Kisaran Harga(2026)

| Budget | Model | RAM | SSD |
|--------|-------|-----|-----|
| 8-12 juta | MacBook Air M1 | 16GB | 256GB |
| 12-18 juta | MacBook Pro 14" M1 Pro | 16GB | 512GB |
| 18-25 juta | MacBook Pro 14" M2 Pro | 16GB | 512GB |
| 25+ juta | MacBook Pro 16" M2 Max | 32GB | 1TB |

---

## 📱 Quick Reference Commands

```bash
# === SSD Health ===
sudo smartctl -a disk0

# === Battery Health ===
system_profiler SPPowerDataType | grep -E "Cycle|Condition|Capacity"

# === System Info ===
system_profiler SPHardwareDataType

# === Check for MDM ===
profiles list

# === Disk Info ===
diskutil list
diskutil info disk0

# === Memory Pressure ===
memory_pressure

# === Check Swap Usage ===
sysctl vm.swapusage
```

---

## 📋 Printable Checklist

```
CHECKLIST MEMBELI MACBOOK BEKAS
================================

DOKUMEN:
[ ] Invoice/struk
[ ] Box original
[ ] Charger original  
[ ] Info garansi

VERIFIKASI:
[ ] Serial number match (device, box, Apple website)
[ ] Activation Lock OFF
[ ] Find My Mac OFF
[ ] Tidak ada MDM Profile

SSD HEALTH:
[ ] Percentage Used < 30%
[ ] TBW < 50 TB
[ ] Media Errors = 0
[ ] Health = PASSED

BATTERY:
[ ] Cycle Count < 500
[ ] Capacity > 80%
[ ] Condition = Normal

FISIK:
[ ] Layar OK (no dead pixel, stain)
[ ] Keyboard OK
[ ] Trackpad OK
[ ] Speaker OK
[ ] Webcam OK
[ ] Port OK
[ ] Body OK (no dent, crack)

FINAL:
[ ] Test minimal 30 menit
[ ] Benchmark score normal
[ ] Harga reasonable

NOTES:
_________________________________
_________________________________
_________________________________
```

---

*Guide ini dibuat berdasarkan pengalaman dan riset tentang kesehatan SSD MacBook. Untuk update terbaru, cek kembali sumber-sumber terkait. Cek juga script checker yang ada pada repo ini.*
