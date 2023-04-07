BIOS_8088_DIR = 8088_bios
XUB_DIR = xub/XTIDE_Universal_BIOS
GLABIOS_DIR = glabios/src
GLATICK_DIR = glatick/src
FLOPPY_BIOS_DIR = floppy_bios

GLATICK_SRC = \
	$(GLATICK_DIR)/GLALIB.ASM \
	$(GLATICK_DIR)/GLALIB.INC \
	$(GLATICK_DIR)/GLATICK.ASM \
	$(GLATICK_DIR)/MACROS.INC \
	$(GLATICK_DIR)/RTC_AT.ASM \
	$(GLATICK_DIR)/RTC.INC \
	$(GLATICK_DIR)/RTC_NS.ASM \
	$(GLATICK_DIR)/RTC_OK.ASM \
	$(GLATICK_DIR)/RTC_RP.ASM \
	$(GLATICK_DIR)/SEGS.INC \
	rtc.patch

$(BIOS_8088_DIR)/bios.bin:
	$(MAKE) -C $(BIOS_8088_DIR) bios.bin

$(XUB_DIR)/Build/ide_xtp.bin:
	$(MAKE) -C $(XUB_DIR) USE_NEC_V=1 AS=nasm xtplus
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xtp.bin 8192

$(XUB_DIR)/Build/ide_xt.bin:
	$(MAKE) -C $(XUB_DIR) AS=nasm xt
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xt.bin 8192

$(GLABIOS_DIR)/GLANUXT.ASM: $(GLABIOS_DIR)/GLABIOS.ASM
	sed 's/^MICRO_8088.*=.*/MICRO_8088=1/g' $< >$@

$(GLABIOS_DIR)/GLANUXT8.ROM: $(GLABIOS_DIR)/GLANUXT.ASM
	dosbox GBN8.BAT -exit -c "MOUNT D \"masm" -c "PATH D:;Z:"

$(GLABIOS_DIR)/GLANUXTV.ROM: $(GLABIOS_DIR)/GLANUXT.ASM
	dosbox GBNV.BAT -exit -c "MOUNT D \"masm" -c "PATH D:;Z:"

$(GLATICK_DIR)/GLATICK.ROM: $(GLATICK_SRC)
	-patch -r /dev/null -N glatick/src/RTC.INC rtc.patch
	dosbox TICKMK.BAT -exit -c "MOUNT D \"masm" -c "PATH D:;Z:"

$(FLOPPY_BIOS_DIR)/floppy_bios.bin:
	$(MAKE) -C $(FLOPPY_BIOS_DIR) floppy_bios.bin

ide_xt_v20.bin: $(XUB_DIR)/Build/ide_xtp.bin
	cp $< $@

ide_xt_8088.bin: $(XUB_DIR)/Build/ide_xt.bin
	cp $< $@

bios8088.bin: $(BIOS_8088_DIR)/bios.bin
	cp $< $@

floppy_bios.bin: $(FLOPPY_BIOS_DIR)/floppy_bios.bin
	cp $< $@

glabios_nuxt_8088.bin: $(GLABIOS_DIR)/GLANUXT8.ROM
	cp $< $@

glabios_nuxt_v20.bin: $(GLABIOS_DIR)/GLANUXTV.ROM
	cp $< $@

glatick.bin: $(GLATICK_DIR)/GLATICK.ROM
	cp $< $@

bios-nuxt-v20-micro-glabios.bin: bios8088.bin ide_xt_v20.bin glabios_nuxt_v20.bin floppy_bios.bin glatick.bin
# First 64 KiB, Micro 8088 BIOS + XT-IDE
# F000-F1FF XT-IDE
# F200-F7FF Empty
# F800-F9FF Empty
# FA00-FFFF Micro 8088
	cat ide_xt_v20.bin > $@
	dd if=/dev/zero ibs=1k count=24 | LANG=C tr "\000" "\377" >> $@
	dd if=/dev/zero ibs=1k count=8 | LANG=C tr "\000" "\377" >> $@
	cat bios8088.bin >> $@

# Second 64 KiB, GLaBIOS + GLaTICK + Multi-Floppy + XT-IDE
# F000-F1FF XT-IDE
# F200-F7FF Empty
# F800-FB7F Empty
# FB80-FBFF GLaTICK
# FC00-FDFF Multi-Floppy
# FE00-FFFF GLaBIOS
	cat ide_xt_v20.bin >> $@
	dd if=/dev/zero ibs=1k count=24 | LANG=C tr "\000" "\377" >> $@
	dd if=/dev/zero ibs=1k count=14 | LANG=C tr "\000" "\377" >> $@
	cat glatick.bin >> $@
	cat floppy_bios.bin >> $@
	cat glabios_nuxt_v20.bin >> $@


bios-nuxt-8088-micro-glabios.bin: bios8088.bin ide_xt_8088.bin glabios_nuxt_8088.bin floppy_bios.bin glatick.bin
# First 64 KiB, Micro 8088 BIOS + XT-IDE
# F000-F1FF XT-IDE
# F200-F7FF Empty
# F800-F9FF Empty
# FA00-FFFF Micro 8088
	cat ide_xt_8088.bin > $@
	dd if=/dev/zero ibs=1k count=24 | LANG=C tr "\000" "\377" >> $@
	dd if=/dev/zero ibs=1k count=8 | LANG=C tr "\000" "\377" >> $@
	cat bios8088.bin >> $@

# Second 64 KiB, GLaBIOS + GLaTICK + Multi-Floppy + XT-IDE
# F000-F1FF XT-IDE
# F200-F7FF Empty
# F800-FB7F Empty
# FB80-FBFF GLaTICK
# FC00-FDFF Multi-Floppy
# FE00-FFFF GLaBIOS
	cat ide_xt_8088.bin >> $@
	dd if=/dev/zero ibs=1k count=24 | LANG=C tr "\000" "\377" >> $@
	dd if=/dev/zero ibs=1k count=14 | LANG=C tr "\000" "\377" >> $@
	cat glatick.bin >> $@
	cat floppy_bios.bin >> $@
	cat glabios_nuxt_8088.bin >> $@

modules: bios8088.bin ide_xt_8088.bin ide_xt_v20.bin glabios_nuxt_8088.bin glabios_nuxt_v20.bin glatick.bin floppy_bios.bin

clean:
	@-rm -f bios8088.bin ide_xt_8088.bin ide_xt_v20.bin glabios_nuxt_8088.bin glabios_nuxt_v20.bin glatick.bin floppy_bios.bin
	@-$(MAKE) -s -C $(BIOS_8088_DIR) clean
	@-$(MAKE) -s -C $(FLOPPY_BIOS_DIR) clean
	@-rm -f $(XUB_DIR)/Build/*
	@-rm -f $(GLABIOS_DIR)/GLANUXT.ASM
	@-rm -f $(GLABIOS_DIR)/*.ROM $(GLABIOS_DIR)/*.OBJ $(GLABIOS_DIR)/*.EXE
	@-rm -f $(GLATICK_DIR)/*.OBJ $(GLATICK_DIR)/*.LST $(GLATICK_DIR)/GLATICK.ROM $(GLATICK_DIR)/GLATICK.MAP $(GLATICK_DIR)/GLATICK.EXE
	@-rm -f bios-nuxt-v20-micro-glabios.bin bios-nuxt-8088-micro-glabios.bin
