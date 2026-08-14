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

LOCAL_PATH := device/oppo/A37f

# TWRP specific build flags
TW_DEFAULT_LANGUAGE := en-US
TW_NO_USB_STORAGE := true
BOARD_SUPPRESS_SECURE_ERASE := true
BOARD_HAS_REMOVABLE_STORAGE := true
TW_MAX_BRIGHTNESS := 100
TW_DEFAULT_BRIGHTNESS := "70"
BOARD_HAS_NO_REAL_SDCARD := true
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_IGNORE_ABS_MT_TRACKING_ID := true
TW_USE_TOOLBOX := true
TW_CRYPTO_USE_SBIN_VOLD := true
TW_THEME := portrait_hdpi
# lis3dh-accel DITAMBAHKAN — penyebab layar tersentuh sendiri.
#
# TWRP membaca SEMUA /dev/input/event* dan menafsirkan EV_ABS ABS_X/ABS_Y
# sebagai koordinat sentuhan. Akselerometer melaporkan sumbu yang sama, jadi
# tanpa blacklist ia terbaca sebagai jari yang bergerak terus-menerus.
#
# Bukti dari perangkat (getevent -l, layar tidak disentuh sama sekali):
#   /dev/input/event4  lis3dh-accel   membanjiri ABS_X/ABS_Y/ABS_Z tanpa henti
#   /dev/input/event0  synaptics-s3203  (touchscreen asli) DIAM
#
# Daftar bawaan TWRP tidak menolongnya — minuitwrp/events.cpp:202 hanya memuat
# dua akselerometer:
#     if (strcmp(e->deviceName, "bma250") == 0 || strcmp(e->deviceName, "bma150") == 0)
# Perangkat ini memakai lis3dh, jadi lolos dari daftar itu.
#
# Pemisahnya \x0a (newline); events.cpp:210 mem-parse dengan strtok(bl, "\n")
# dan mencocokkan dengan strcmp EKSAK — jadi nama harus persis seperti yang
# muncul di /proc/bus/input/devices.
#
# hbtp_vm dipertahankan: sudah terbukti bekerja (recovery.log:34
# "Blacklisting input device: hbtp_vm") dan ia memegang handler mouse0.
#
# Sensor lain (compass, light, proximity) TIDAK dimasukkan: ketiganya tidak
# muncul sama sekali di log getevent, dan memblokir yang tidak terbukti
# bermasalah hanya menambah selisih dari device tree hulu tanpa alasan.
TW_INPUT_BLACKLIST := "hbtp_vm\x0alis3dh-accel"

#adbd insecure
BOARD_ALWAYS_INSECURE := true
