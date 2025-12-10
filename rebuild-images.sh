#!/bin/sudo bash
# shellcheck shell=bash
#
# rebuild.sh -
# Copyright Peter Jones <pjones@redhat.com>
#
# Distributed under terms of the GPLv3 license.
#

set -eu
set -o pipefail
set -x

# Fedora-Server-netinst-x86_64-43-1.6
# Fedora-Server-netinst-x86_64-43-1.6.img
# Fedora-Server-netinst-x86_64-43-1.6.iso
# Fedora-Server-netinst-x86_64-43-1.6.msft2011.msft2023
# Fedora-Server-netinst-x86_64-43-1.6.msft2011.msft2023.img
# Fedora-Server-netinst-x86_64-43-1.6.msft2023
# Fedora-Server-netinst-x86_64-43-1.6.msft2023.img
# Fedora-Server-netinst-x86_64-43-1.6.msft2023.msft2011
# Fedora-Server-netinst-x86_64-43-1.6.msft2023.msft2011.img
# 'Microsoft UEFI CA 2023.crt'
# msft2011.cer
# msft2023.cer
# shimx64.efi
# shimx64.msft2011.efi
# shimx64.msft2011.msft2023.efi
# shimx64.msft2011.sig
# shimx64.msft2023.efi
# shimx64.msft2023.msft2011.efi
# shimx64.msft2023.sig
# show-trusted.sh
# tmp
# edk2-20251119-2.copr9865483
# edk2-20251119-2.copr9865483.src.rpm

unmount()
{
    local prefix="Fedora-Server-netinst-x86_64-43-1.6"
    for x in msft2011.msft2023 msft2023.msft2011 msft2011 msft2023 ; do
        umount "${prefix}.${x}/" || :
    done
}

main()
{
    unmount >/dev/null 2>&1
    trap unmount ERR INT TERM

    rm -vf shimx64.msft*.efi
    pesign -i shimx64.efi -m shimx64.msft2011.sig -o shimx64.msft2011.efi
    pesign -i shimx64.efi -m shimx64.msft2023.sig -o shimx64.msft2023.efi
    pesign -i shimx64.msft2023.efi -u 1 -m shimx64.msft2011.sig -o shimx64.msft2023.msft2011.efi
    pesign -i shimx64.msft2011.efi -u 1 -m shimx64.msft2023.sig -o shimx64.msft2011.msft2023.efi

    local prefix="Fedora-Server-netinst-x86_64-43-1.6"
    for x in msft2011.msft2023 msft2023.msft2011 msft2023 msft2011 ; do
        mount -o loop "${prefix}.${x}.img" "${prefix}.${x}/"
        cp "shimx64.${x}.efi" "${prefix}.${x}/EFI/BOOT/BOOTX64.EFI"
        umount "${prefix}.${x}"
    done
}

main "$@"

# vim:fenc=utf-8:tw=75
