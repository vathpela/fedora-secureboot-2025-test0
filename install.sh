#!/bin/bash
# SPDX-License-Identifier: GPLv3
#
# install.sh - install the test bootloader named on the command line
# Copyright Peter Jones <pjones@redhat.com>
#
# Distributed under terms of the GPLv3 license.
#

set -eu
set -o pipefail

progname="$0"

usage() {
    local errcode="$1" && shift
    local output

    if [ "$errcode" -eq 0 ]; then
        output=/dev/stdout
    else
        output=/dev/stderr
    fi

    if [ $# -gt 0 ]; then
        echo "$@" > "${output}"
    fi
    echo "usage: $progname TESTNAME" > "${output}"
    exit "${errcode}"
}

main() {
    local bootloader
    if [ $# -eq 0 ]; then
        usage 1
    fi
    while [ $# -gt 0 ] ; do
        case " ${1} " in
            " -? "|" -h "|" --help "|" --usage ")
                usage 0
                ;;
            *)
                if [ -v bootloader ]; then
                    usage 1 "too many arguments"
                fi
                bootloader="${1}"
                shift
                ;;
        esac
    done

    if [ ! -v bootloader ] || [ -z "${bootloader}" ]; then
        usage 1
    fi

    local num
    num="$(efibootmgr | grep "[ 	]${bootloader}[ 	]" | cut -d\  -f1 | cut -dt -f2 | cut '-d*' -f1)" || :
    local device
    device="$(mount | grep " on /boot/efi " | cut -d\  -f1)"
    if [ -z "${num}" ]; then
        efibootmgr -C -d "${device}" -L "${bootloader}" -l "\\EFI\\BOOT\\shimx64.efi" --quiet
    fi
    num="$(efibootmgr | grep "[ 	]${bootloader}[ 	]" | cut -d\  -f1 | cut -dt -f2 | cut '-d*' -f1)"
    local order
    order="$(efibootmgr | grep BootOrder: | cut -d\  -f2)" || :
    if [ -z "${order}" ]; then
        order="${num}"
    else
        order="${order},${num}"
    fi
    efibootmgr -o "${order}" --quiet
}

main "$@"

# vim:fenc=utf-8:tw=75
