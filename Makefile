# SPDX-License-Identifier: GPLv3
#
# Makefile
# Copyright Peter Jones <pjones@redhat.com>
#

ONESHELL = 1

SIG0 = msft2011.msft2023
SIG1 = msft2023.msft2011
SIG2 = msft2023

SIGS = $(SIG0) $(SIG1) $(SIG2)

IMG_PREFIX = Fedora-Server-netinst-x86_64-43-1.6

TARGETS = $(foreach n,$(SIGS),shimx64.$(n).efi) \
	  $(foreach n,$(SIGS),$(IMG_PREFIX).$(n).img) \
	  $(foreach n,$(SIGS),x86_64/shimx64.$(n)-1-1.x86_64.rpm)

all : $(TARGETS)

shimx64.msft2011.efi : shimx64.msft2011.sig
	pesign -i shimx64.efi -m shimx64.msft2011.sig -o $@

shimx64.msft2023.efi : shimx64.msft2023.sig
	pesign -i shimx64.efi -m shimx64.msft2023.sig -o $@

shimx64.msft2011.msft2023.efi : shimx64.msft2011.efi shimx64.msft2023.sig
	pesign -i shimx64.msft2011.efi -m shimx64.msft2023.sig -o $@

shimx64.msft2023.msft2011.efi : shimx64.msft2023.efi shimx64.msft2011.sig
	pesign -i shimx64.msft2023.efi -m shimx64.msft2011.sig -o $@

$(IMG_PREFIX).msft2011.msft2023.img : $(IMG_PREFIX)/ shimx64.msft2011.msft2023.efi
	./make-image.sh $@ $^

$(IMG_PREFIX).msft2023.msft2011.img : $(IMG_PREFIX)/ shimx64.msft2023.msft2011.efi
	./make-image.sh $@ $^

$(IMG_PREFIX).msft2023.img : $(IMG_PREFIX)/ shimx64.msft2023.efi
	./make-image.sh $@ $^

$(IMG_PREFIX).msft2011.img : $(IMG_PREFIX)/ shimx64.msft2011.efi
	./make-image.sh $@ $^

$(foreach n,$(SIGS),shimx64.$(n).spec) : %.spec : fsb25tN.spec.in
	sed \
		-e 's/@@TESTLOADER@@/$*/g' \
	<$< >$@

$(foreach n,$(SIGS),shimx64.$(n)-1-1.src.rpm) : shimx64.%-1-1.src.rpm : shimx64.%.spec shimx64.%.efi
	rpmbuild --here -bs $<

$(foreach n,$(SIGS),x86_64/shimx64.$(n)-1-1.x86_64.rpm) : x86_64/shimx64.%-1-1.x86_64.rpm : shimx64.%-1-1.src.rpm
	mock -r fedora-43-x86_64 --rebuild $<
	mkdir -p x86_64
	mv -v /var/lib/mock/fedora-*-x86_64/result/shimx64.$*-1-1.x86_64.rpm x86_64/

clean :
	rm -vf $(foreach n,$(SIGS),shimx64.$(n).spec)
	rm -vf shimx64.msft*.efi shimx64.msft*.rpm
	rm -vf $(IMG_PREFIX).msft*.img
	rm -vrf x86_64/

# vim:ft=make
