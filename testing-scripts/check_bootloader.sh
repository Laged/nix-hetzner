#!/bin/bash

# Read the bootloader_type value from /proc/sys/kernel/bootloader_type
bootloader_value=$(cat /proc/sys/kernel/bootloader_type)

# Shift the value right by 4 bits
bootloader_type=$(( bootloader_value >> 4 ))

# Interpret the bootloader type
case $bootloader_type in
  0)
    bootloader_name="No bootloader"
    ;;
  1)
    bootloader_name="LILO (Linux Loader)"
    ;;
  2)
    bootloader_name="GRUB (GRand Unified Bootloader)"
    ;;
  3)
    bootloader_name="SYSLINUX"
    ;;
  4)
    bootloader_name="Gummiboot/systemd-boot"
    ;;
  5)
    bootloader_name="UEFI firmware"
    ;;
  *)
    bootloader_name="Unknown bootloader"
    ;;
esac

# Output the result
echo "Bootloader Type: $bootloader_type ($bootloader_name)"

