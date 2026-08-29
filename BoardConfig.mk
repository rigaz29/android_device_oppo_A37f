#
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FORCE_32_BIT := true
DEVICE_PATH := device/oppo/A37f

# Architecture
TARGET_BOARD_SUFFIX := _32
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53

TARGET_BOARD_PLATFORM := msm8916
TARGET_BOARD_PLATFORM_GPU := qcom-adreno306
TARGET_PLATFORM_DEVICE_BASE := /devices/soc.0/

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8916
TARGET_NO_BOOTLOADER := true

# Kernel
BOARD_KERNEL_BASE := 0x80000000
# ramoops.ecc=1 — WAJIB SAMA dengan device tree LOS (rb_device_oppo_A37).
#
# ECC mengubah TATA LETAK buffer, bukan cuma cara membacanya (ram_core.c:212
# memangkas buffer_size dan menaruh paritas di ekornya). Recovery ini MEMBACA
# buffer yang ditulis kernel ROM; kalau salah satu memakai ECC dan yang lain
# tidak, pembaca akan memperlakukan data log sebagai paritas dan "mengoreksi"
# isinya jadi rusak. Ubah keduanya atau tidak sama sekali.
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 androidboot.selinux=permissive ramoops.mem_address=0x9ff00000 ramoops.mem_size=0x400000 ramoops.record_size=0x40000 ramoops.console_size=0x100000 ramoops.pmsg_size=0x40000 ramoops.dump_oops=1 ramoops.ecc=1
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_KERNEL_IMAGE_NAME := Image
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --dt $(DEVICE_PATH)/prebuilt/dt.img

# Filesystem
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_CACHEIMAGE_PARTITION_SIZE := 126877696
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2859466752
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11632902144

# Assert
TARGET_OTA_ASSERT_DEVICE := a37f,A37f,A37fw,a37fw,msm8916,msm8939

# Crypto
TW_INCLUDE_CRYPTO := true
TARGET_CRYPTFS_HW_PATH := vendor/qcom/opensource/commonsys/cryptfs_hw

# FBE. REDUNDAN secara teknis: bootable/recovery/Android.mk:347-358 sudah
# menyetel TW_INCLUDE_CRYPTO_FBE sendiri begitu TW_INCLUDE_CRYPTO=true dan
# PLATFORM_SDK_VERSION >= 24 (twrp-9.0 adalah SDK 28). Ditulis eksplisit karena
# syarat itu bergantung pada versi SDK lingkungan build, bukan pada niat kita --
# dan supaya jelas bahwa FBE memang disengaja, bukan efek samping.
#
# Yang ditariknya: crypto/ext4crypt, yang menaut
# android.hardware.keymaster@3.0 (crypto/ext4crypt/Android.mk:20) -- persis HAL
# yang dimiliki A37, terverifikasi berjalan di perangkat.
#
# Jalur yang dipakai Ext4CryptPie (crypto/ext4crypt/Decrypt.cpp:19,165), dan
# NAME_PREFIXES-nya { "ext4", "f2fs", "fscrypt" }
# (crypto/ext4crypt/KeyUtil.cpp:103) IDENTIK dengan vold Android 16
# (system/vold/KeyUtil.cpp:142). Tipe kunci sama (logon), format nama sama
# (prefix:hex), dan keduanya bicara ke kernel fscrypt v1 yang sama.
TW_INCLUDE_CRYPTO_FBE := true

# Recovery
TARGET_USERIMAGES_USE_EXT4 := true
# Tanpa ini mkfs.f2fs dan fsck.f2fs TIDAK ikut dibangun
# (bootable/recovery/Android.mk:581-585), sehingga TWRP tidak bisa memformat
# /data menjadi f2fs -- padahal f2fs adalah satu-satunya filesystem yang
# tersambung ke fscrypt di kernel kita (fs/f2fs/super.c:1222; fs/ext4/ nol
# dukungan enkripsi).
TARGET_USERIMAGES_USE_F2FS := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/etc/twrp.fstab
BOARD_HAS_NO_SELECT_BUTTON := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBA_8888"

# Timezone package
PRODUCT_COPY_FILES += \
    system/timezone/output_data/iana/tzdata:recovery/root/system_root/system/usr/share/zoneinfo/tzdata

# LZMA ramdisk compression
LZMA_RAMDISK_TARGETS := recovery
LZMA_COMPRESSION := -9
