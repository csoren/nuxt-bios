BIOS_8088_DIR=8088_bios
XUB_DIR=xub/XTIDE_Universal_BIOS
GLABIOS_DIR=glabios/src

$(BIOS_8088_DIR)/bios.bin:
	$(MAKE) -C $(BIOS_8088_DIR) bios.bin

$(XUB_DIR)/Build/ide_xtp.bin:
	$(MAKE) -C $(XUB_DIR) USE_NEC_V=1 AS=nasm xtplus
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xtp.bin 8192

$(XUB_DIR)/Build/ide_xt.bin:
	$(MAKE) -C $(XUB_DIR) AS=nasm xt
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xt.bin 8192

$(GLABIOS_DIR)/GLABIOS8.ROM: $(GLABIOS_DIR)/GLABIOS.ASM
	dosbox GLMK8088.BAT -exit -c "MOUNT D \"masm" -c "PATH D:;Z:"

$(GLABIOS_DIR)/GLABIOSV.ROM: $(GLABIOS_DIR)/GLABIOS.ASM
	dosbox GLMKV20.BAT -exit -c "MOUNT D \"masm" -c "PATH D:;Z:"

ide_xt_v20.bin: $(XUB_DIR)/Build/ide_xtp.bin
	cp $< $@

ide_xt_8088.bin: $(XUB_DIR)/Build/ide_xt.bin
	cp $< $@

bios8088.bin: $(BIOS_8088_DIR)/bios.bin
	cp $< $@

glabios_8088.bin: $(GLABIOS_DIR)/GLABIOS8.ROM
	cp $< $@

glabios_v20.bin: $(GLABIOS_DIR)/GLABIOSV.ROM
	cp $< $@

bios-nuxt-glabios-v20.bin: bios8088.bin ide_xt_v20.bin glabios_v20.bin
	cat ide_xt_v20.bin > $@
	dd if=/dev/zero ibs=1k count=32 | LANG=C tr "\000" "\377" >> $@
	cat bios8088.bin >> $@
	cat ide_xt_v20.bin >> $@
	dd if=/dev/zero ibs=1k count=48 | LANG=C tr "\000" "\377" >> $@
	cat glabios_v20.bin >> $@

clean:
	@-rm -f bios8088.bin ide_xt_8088.bin ide_xt_v20.bin glabios_8088.bin glabios_v20.bin
	@-make -s -C $(BIOS_8088_DIR) clean
	@-rm -f $(XUB_DIR)/Build/*
	@-rm -f $(GLABIOS_DIR)/GLABIOS8.ROM $(GLABIOS_DIR)/GLABIOSV.ROM $(GLABIOS_DIR)/GLABIOS.OBJ $(GLABIOS_DIR)/GLABIOS.EXE
	@-rm bios-nuxt-glabios-v20.bin