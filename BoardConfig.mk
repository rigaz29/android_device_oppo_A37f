#
# BoardConfig TWRP untuk OPPO A37f, basis twrp-12.1.
#
# Diturunkan dari device tree A37f basis android-9.0 (rigaz29/android_device_
# oppo_A37f@3e0b507) dengan struktur 12.1 dari rujukan acroreiser
# (android_device_lenovo_a6010, branch twrp-12.1) -- perangkat msm8916/kernel
# 3.10 yang sudah terbukti mendekripsi FBE dari recovery.
#
# Alasan pindah dari 9.0 ke 12.1, keduanya terverifikasi dari sumber:
#
#   1. vold TeamWin android-12.1 sudah memakai format kunci modern.
#      system/vold/KeyStorage.cpp:74 memuat komentar yang IDENTIK dengan
#      Android 16 ("old key directories may contain a file named 'stretching'")
#      dan :438 memakai appId = secdiscardable_hash + auth.secret yang juga
#      identik. TWRP 9.0 masih menuntut berkas "stretching" yang vold Android 16
#      tidak pernah tulis, sehingga butuh tambalan (diarsipkan di repo rencana,
#      patches-twrp9/).
#
#   2. Layout /system/bin di ramdisk 12.1 menghilangkan masalah interpreter ELF.
#      Di 9.0 biner HAL meminta /system/bin/linker sementara ramdisk hanya punya
#      /sbin/linker, sehingga execve gagal dengan ENOENT yang menyesatkan.
#

FORCE_32_BIT := true
DEVICE_PATH := device/oppo/A37f

# Platform
TARGET_BOARD_PLATFORM := msm8916
TARGET_BOARD_PLATFORM_GPU := qcom-adreno306
TARGET_BOOTLOADER_BOARD_NAME := MSM8916
TARGET_NO_BOOTLOADER := true

# Arsitektur -- kernel arm64, userspace 32-bit
TARGET_BOARD_SUFFIX := _32
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53

PRODUCT_ENFORCE_VINTF_MANIFEST_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_USES_64_BIT_BINDER := true

# Kernel
#
# cmdline mempertahankan parameter ramoops dari pekerjaan sebelumnya -- itu yang
# memungkinkan mendiagnosis bootloop FBE kemarin lewat console-ramoops. Tanpa
# itu "berhenti di logo lalu reboot" adalah gejala buta.
#
# BOARD_RAMDISK_OFFSET WAJIB 0x02000000 di sini, BUKAN 0x01000000 seperti LOS.
# Kernel kita jauh lebih besar dari kernel stock; dengan offset 0x01000000
# ramdisk tumpang tindih dengan kernel dan isinya rusak. Ubah keduanya atau
# tidak sama sekali.
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 androidboot.selinux=permissive ramoops.mem_address=0x9ff00000 ramoops.mem_size=0x400000 ramoops.record_size=0x40000 ramoops.console_size=0x100000 ramoops.pmsg_size=0x40000 ramoops.dump_oops=1 ramoops.ecc=1
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_KERNEL_IMAGE_NAME := Image

# Kernel dari build LineageOS 23.2 (kernel_oppo_msm8939@d055d768d26), memuat
# CONFIG_FS_ENCRYPTION, CONFIG_F2FS_FS_ENCRYPTION, dan CONFIG_KEYS_COMPAT.
# Yang terakhir itu WAJIB dan tidak ada di kernel 3.10 hulu untuk arm64: tanpanya
# security/keys/compat.o tidak dibangun, compat_sys_keyctl tidak ada, dan setiap
# keyctl() dari userspace 32-bit mengembalikan ENOSYS -- sistem bootloop saat FBE
# aktif. Rujukan a6010 tidak bisa mengajarkan ini; kernel mereka arm 32-bit murni
# sehingga lapisan compat tidak pernah terlibat.
#
# Berbeda dari a6010 yang memakai zImage-dtb (DTB ditempel), kernel kita memakai
# Image terpisah dengan dt.img lewat --dt.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --dt $(DEVICE_PATH)/prebuilt/dt.img

BOARD_RAMDISK_USE_XZ := true

# Filesystem
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_CACHEIMAGE_PARTITION_SIZE := 126877696
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2859466752
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11632902144
TARGET_USERIMAGES_USE_EXT4 := true
# f2fs wajib: /data kini f2fs, dan tanpa flag ini mkfs.f2fs/fsck.f2fs tidak ikut
# dibangun sehingga TWRP tidak bisa memformatnya.
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true
TW_INCLUDE_FUSE_NTFS := true

# Recovery
# Di layout 12.1 /etc adalah SYMLINK ke /system/etc. Menaruh direktori
# recovery/root/etc/ membuat build gagal dengan "could not make way for new
# symlink: root/etc". Berkasnya diletakkan di system/etc dan tetap terlihat di
# /etc lewat symlink itu.
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBA_8888"
TARGET_RECOVERY_QCOM_RTC_FIX := true

# TWRP
BOARD_HAS_REMOVABLE_STORAGE := true
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true
TW_THEME := portrait_hdpi
TW_MAX_BRIGHTNESS := 100
TW_DEFAULT_BRIGHTNESS := "70"
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := en-US
TW_NO_SCREEN_TIMEOUT := true
TW_NO_EXFAT := false
TW_NO_USB_STORAGE := false
TW_USE_TOOLBOX := true
TW_IGNORE_ABS_MT_TRACKING_ID := true
# lis3dh-accel diblokir bersama hbtp_vm. Keduanya TERBUKTI ada di A37 --
# report/input-devices.txt mencatat sembilan perangkat input: synaptics-s3203,
# synaptics-s3203-kpd, hbtp_vm, compass, lis3dh-accel, light, proximity,
# qpnp_pon, gpio-keys. Default TWRP hanya memblokir bma250/bma150
# (minuitwrp/events.cpp:243) sehingga tidak menolong di sini.
#
# Pemisahnya "\n", BUKAN "\x0a" seperti yang disarankan komentar TWRP
# (events.cpp:242). Basis 12.1 mengekspor nilai ini ke out/soong/soong.variables
# sebagai JSON, dan "\x" bukan escape JSON yang sah -- soong gagal dengan
# "invalid character 'x' in string escape code" sebelum build dimulai.
# "\n" sah di JSON MAUPUN di string literal C, dan strtok(bl, "\n")
# (events.cpp:250) memang memisah pada newline.
#
# WHITELIST_INPUT bukan alternatif: ia hanya menerima SATU nama perangkat
# (events.cpp:236), sehingga tombol fisik ikut diabaikan.
TW_INPUT_BLACKLIST := "hbtp_vm\nlis3dh-accel"

# Logging -- dibutuhkan untuk mendiagnosis kegagalan dekripsi
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TWRP_EVENT_LOGGING := true

TW_EXCLUDE_APEX := true
BOARD_ALWAYS_INSECURE := true

# FBE
#
# TW_USE_FSCRYPT_POLICY := 1 WAJIB. Kernel A37 hanya punya kebijakan fscrypt v1
# -- fs/crypto/ tidak memuat keyring.c maupun hkdf.c, jadi
# FS_IOC_ADD_ENCRYPTION_KEY tidak ada dan hanya FS_IOC_SET_ENCRYPTION_POLICY
# yang tersedia. Nilai ini cocok dengan fstab ROM yang memakai
# fileencryption=aes-256-xts:aes-256-cts:v1.
#
# TW_FORCE_KEYMASTER_VER dipasangkan dengan properti keymaster_ver=4.1 di
# omni_A37f.mk. Keymaster di A37 murni software ("Could not find any keystore
# module, using software-only implementation" -- keystore.msm8916.so memang tidak
# pernah diekstrak ke vendor blob kita), jadi recovery menjalankan servis
# keymaster software sendiri, bukan HAL vendor.
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_USE_FSCRYPT_POLICY := 1
TW_FORCE_KEYMASTER_VER := true

TARGET_OTA_ASSERT_DEVICE := a37f,A37f,A37fw,a37fw,msm8916,msm8939

PLATFORM_VERSION             := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH      := 2099-12-31
VENDOR_SECURITY_PATCH        := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH          := $(PLATFORM_SECURITY_PATCH)
