BIOS_8088_DIR = 8088_bios
XUB_DIR = xub/XTIDE_Universal_BIOS
GLABIOS_DIR = glabios/src
GLATICK_DIR = glatick/src
FLOPPY_BIOS_DIR = floppy_bios
ARTIFACTS_DIR = bin
BASIC = cbasic/ibm6.rom cbasic/ibm8.rom cbasic/ibma.rom cbasic/ibmc.rom

GLATICK_SRC = \
	$(GLATICK_DIR)/GLALIB.ASM \
	$(GLATICK_DIR)/GLALIB.INC \
	$(GLATICK_DIR)/GLATICK.ASM \
	$(GLATICK_DIR)/MACROS.INC \
	$(GLATICK_DIR)/RTC.INC \
	$(GLATICK_DIR)/RTC_AT.ASM \
	$(GLATICK_DIR)/RTC_NS.ASM \
	$(GLATICK_DIR)/RTC_OK.ASM \
	$(GLATICK_DIR)/RTC_RP.ASM \
	$(GLATICK_DIR)/SEGS.INC \
	rtc.patch

all: bios-nuxt-hybrid-v20.bin bios-nuxt-hybrid-universal.bin

$(BIOS_8088_DIR)/bios.bin:
	$(MAKE) -C $(BIOS_8088_DIR) bios.bin

$(XUB_DIR)/Build/ide_xtp.bin:
	$(MAKE) -C $(XUB_DIR) USE_NEC_V=1 AS=nasm xtplus
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xtp.bin 8192

$(XUB_DIR)/Build/ide_xt.bin:
	$(MAKE) -C $(XUB_DIR) AS=nasm xt
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xt.bin 8192

$(GLABIOS_DIR)/GLANUXT8.ROM: $(GLABIOS_DIR)/GLABIOS.ASM
	dosbox GBN8.BAT -exit -c "MOUNT D \"masm5\"" -c "PATH D:;Z:"

$(GLABIOS_DIR)/GLANUXTV.ROM: $(GLABIOS_DIR)/GLABIOS.ASM
	dosbox GBNV.BAT -exit -c "MOUNT D \"masm5\"" -c "PATH D:;Z:"

$(GLATICK_DIR)/_patched: $(GLATICK_SRC) rtc.patch
	-patch -r /dev/null -N $(GLATICK_DIR)/RTC.INC rtc.patch
	touch $@

$(GLATICK_DIR)/GLATICK.ROM: $(GLATICK_SRC) $(GLATICK_DIR)/_patched
	dosbox TICKMK.BAT -exit -c "MOUNT D \"masm5\"" -c "PATH D:;Z:"

$(FLOPPY_BIOS_DIR)/floppy_bios.bin:
	$(MAKE) -C $(FLOPPY_BIOS_DIR) floppy_bios.bin

$(ARTIFACTS_DIR):
	mkdir -p $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/ide_xt_v20.bin: $(XUB_DIR)/Build/ide_xtp.bin | $(ARTIFACTS_DIR)
	cp $< $@

$(ARTIFACTS_DIR)/ide_xt_8088.bin: $(XUB_DIR)/Build/ide_xt.bin | $(ARTIFACTS_DIR)
	cp $< $@

$(ARTIFACTS_DIR)/micro8088.bin: $(BIOS_8088_DIR)/bios.bin | $(ARTIFACTS_DIR)
	cp $< $@

$(ARTIFACTS_DIR)/floppy_bios.bin: $(FLOPPY_BIOS_DIR)/floppy_bios.bin | $(ARTIFACTS_DIR)
	cp $< $@

$(ARTIFACTS_DIR)/glabios_nuxt_8088.bin: $(GLABIOS_DIR)/GLANUXT8.ROM | $(ARTIFACTS_DIR)
	cp $< $@

$(ARTIFACTS_DIR)/glabios_nuxt_v20.bin: $(GLABIOS_DIR)/GLANUXTV.ROM | $(ARTIFACTS_DIR)
	cp $< $@

$(ARTIFACTS_DIR)/glatick.bin: $(GLATICK_DIR)/GLATICK.ROM | $(ARTIFACTS_DIR)
	cp $< $@

bios-nuxt-micro-v20.bin: $(ARTIFACTS_DIR)/micro8088.bin $(ARTIFACTS_DIR)/ide_xt_v20.bin
# First 64 KiB, Micro 8088 BIOS + XT-IDE
# F000-F1FF XT-IDE
# F200-F7FF Empty
# F800-F9FF Empty
# FA00-FFFF Micro 8088
	cat $(ARTIFACTS_DIR)/ide_xt_v20.bin > $@
	dd if=/dev/zero ibs=1k count=24 | LANG=C tr "\000" "\377" >> $@
	dd if=/dev/zero ibs=1k count=8 | LANG=C tr "\000" "\377" >> $@
	cat $(ARTIFACTS_DIR)/micro8088.bin >> $@

bios-nuxt-glabios-v20.bin: $(ARTIFACTS_DIR)/ide_xt_v20.bin $(ARTIFACTS_DIR)/glabios_nuxt_v20.bin $(ARTIFACTS_DIR)/floppy_bios.bin $(ARTIFACTS_DIR)/glatick.bin $(BASIC)
# F000-F1FF XT-IDE
# F200-F27F GLaTICK
# F280-F47F Multi-Floppy
# F480-F5FF Empty
# F600-FDFF ROM BASIC 1.1
# FE00-FFFF GLaBIOS
	cat $(ARTIFACTS_DIR)/ide_xt_v20.bin >> $@
	cat $(ARTIFACTS_DIR)/glatick.bin >> $@
	cat $(ARTIFACTS_DIR)/floppy_bios.bin >> $@
	dd if=/dev/zero ibs=1k count=6 | LANG=C tr "\000" "\377" >> $@
	cat $(BASIC) >> $@
	cat $(ARTIFACTS_DIR)/glabios_nuxt_v20.bin >> $@

bios-nuxt-micro-universal.bin: $(ARTIFACTS_DIR)/micro8088.bin $(ARTIFACTS_DIR)/ide_xt_8088.bin
# F000-F1FF XT-IDE
# F200-F7FF Empty
# F800-F9FF Empty
# FA00-FFFF Micro 8088
	cat $(ARTIFACTS_DIR)/ide_xt_8088.bin > $@
	dd if=/dev/zero ibs=1k count=24 | LANG=C tr "\000" "\377" >> $@
	dd if=/dev/zero ibs=1k count=8 | LANG=C tr "\000" "\377" >> $@
	cat $(ARTIFACTS_DIR)/micro8088.bin >> $@

bios-nuxt-glabios-universal.bin: $(ARTIFACTS_DIR)/ide_xt_8088.bin $(ARTIFACTS_DIR)/glabios_nuxt_8088.bin $(ARTIFACTS_DIR)/floppy_bios.bin $(ARTIFACTS_DIR)/glatick.bin
# F000-F1FF XT-IDE
# F200-F27F GLaTICK
# F280-F47F Multi-Floppy
# F480-F5FF Empty
# F600-FDFF ROM BASIC 1.1
# FE00-FFFF GLaBIOS
	cat $(ARTIFACTS_DIR)/ide_xt_8088.bin >> $@
	cat $(ARTIFACTS_DIR)/glatick.bin >> $@
	cat $(ARTIFACTS_DIR)/floppy_bios.bin >> $@
	dd if=/dev/zero ibs=1k count=6 | LANG=C tr "\000" "\377" >> $@
	cat $(BASIC) >> $@
	cat $(ARTIFACTS_DIR)/glabios_nuxt_8088.bin >> $@

modules: $(ARTIFACTS_DIR)/micro8088.bin $(ARTIFACTS_DIR)/ide_xt_8088.bin $(ARTIFACTS_DIR)/ide_xt_v20.bin $(ARTIFACTS_DIR)/glabios_nuxt_8088.bin $(ARTIFACTS_DIR)/glabios_nuxt_v20.bin $(ARTIFACTS_DIR)/glatick.bin $(ARTIFACTS_DIR)/floppy_bios.bin

bios-nuxt-hybrid-v20.bin: bios-nuxt-micro-v20.bin bios-nuxt-glabios-v20.bin
	cat $^ >> $@

bios-nuxt-hybrid-universal.bin: bios-nuxt-micro-universal.bin bios-nuxt-glabios-universal.bin
	cat $^ >> $@

clean:
	@-rm -rf $(ARTIFACTS_DIR)
	@-$(MAKE) -s -C $(BIOS_8088_DIR) clean
	@-$(MAKE) -s -C $(FLOPPY_BIOS_DIR) clean
	@(cd $(FLOPPY_BIOS_DIR); git checkout floppy_bios.bin)
	@-rm -f $(XUB_DIR)/Build/*
	@-rm -f $(GLABIOS_DIR)/*.ROM $(GLABIOS_DIR)/*.OBJ $(GLABIOS_DIR)/*.EXE
	@-rm -f $(GLATICK_DIR)/*.OBJ $(GLATICK_DIR)/*.LST $(GLATICK_DIR)/GLATICK.ROM $(GLATICK_DIR)/GLATICK.MAP $(GLATICK_DIR)/GLATICK.EXE
	@-rm -f bios-nuxt-*.bin
	@(cd $(GLATICK_DIR); git checkout RTC.INC)
	@-rm -f $(GLATICK_DIR)/_patched
