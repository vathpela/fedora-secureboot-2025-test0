#!/usr/bin/sudo /bin/bash
# shellcheck shell=bash
# SPDX-License-Identifier: GPLv3
#
# make-image.sh - make an image
# Copyright Peter Jones <pjones@redhat.com>
#
# Distributed under terms of the GPLv3 license.
#

set -eu
set -o pipefail
set -x

output=""
outmount=""

cleanup()
{
    sync
    if [ -n "${output}" ] && [ -f "${output}" ]; then
        rm -vf "${output}"
    fi
    if [ -n "${outmount}" ] && [ -d "${outmount}" ]; then
        umount "${outmount}" || :
        rmdir "${outmount}" || :
    fi
}

main()
{
    local input
    local shim

    output="$1" && shift
    input="$1" && shift
    shim="$1" && shift

    trap cleanup ERR INT TERM

    outmount="$(mktemp -p . -d)"

    dd if=/dev/zero count=15 bs=1M of="${output}"
    mkfs.vfat -n "ANACONDA   " "${output}"

    mount -o loop "${output}" "${outmount}"

    rsync -avSHP --no-owner --no-group "${input}/" "${outmount}/"
    cp "${shim}" "${outmount}/EFI/BOOT/BOOTX64.EFI"

    sync
    umount "${outmount}"
    rmdir "${outmount}"
}

main "$@"

# vim:fenc=utf-8:tw=75
