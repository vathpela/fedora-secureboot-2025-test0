#!/bin/bash
# SPDX-License-Identifier: GPLv3-or-later 
#
# show-trusted.sh - show which MS certs are trusted by the local system
# Copyright Peter Jones <pjones@redhat.com>
#
# Distributed under terms of the GPLv3 license.
#

set -eu
set -o pipefail

grepqbap() {
    grep -q -b -a --perl-regexp "${1}" "${2}"
}

main() {
    if ! [ -d /sys/firmware/efi/efivars/ ]; then
        echo "System has no EFI runtime"
        exit 0
    fi
    if ! [ -f /sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c ]; then
        echo "SecureBoot variable is missing"
    else
        if grepqbap "\x06\x00\x00\x00\x01" /sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c ; then
            echo "Secure Boot is enabled"
        else
            echo "Secure Boot is disabled"
        fi
    fi
    if ! [ -f /sys/firmware/efi/efivars/SetupMode-8be4df61-93ca-11d2-aa0d-00e098032b8c ]; then
        echo "SetupMode variable is missing"
    else
        if grepqbap "\x06\x00\x00\x00\x01" /sys/firmware/efi/efivars/SetupMode-8be4df61-93ca-11d2-aa0d-00e098032b8c ; then
            echo "System is in Setup Mode"
        else
            echo "System is not in Setup Mode"
        fi
    fi
    if ! [ -f /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f ]; then
        echo "Secure Boot db is not set"
    else
        if grep -q "Third Party Marketplace Root" /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f ; then
            echo "Microsoft 2011 certificate is enrolled"
        else
            echo "Microsoft 2011 certificate is not enrolled"
        fi
        if grep -q "Microsoft UEFI CA 2023" /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f ; then
            echo "Microsoft 2023 certificate is enrolled"
        else
            echo "Microsoft 2023 certificate is not enrolled"
        fi
    fi
}

main "$@"

# vim:fenc=utf-8:tw=75
