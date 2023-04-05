BIOS_8088_DIR=8088_bios
XUB_DIR=xub/XTIDE_Universal_BIOS
GLABIOS_DIR=glabios/src

$(BIOS_8088_DIR)/bios.bin:
	$(MAKE) -C $(BIOS_8088_DIR) bios.bin

$(XUB_DIR)/Build/ide_xtp.bin:
	$(MAKE) -C $(XUB_DIR) AS=nasm xtplus
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xtp.bin 8192

$(XUB_DIR)/Build/ide_xt.bin:
	$(MAKE) -C $(XUB_DIR) AS=nasm xt
	perl $(XUB_DIR)/../Tools/checksum.pl $(XUB_DIR)/Build/ide_xt.bin 8192

$(GLABIOS_DIR)/GLABIOS.ROM: $(GLABIOS_DIR)/GLABIOS.ASM
	cd $(GLABIOS_DIR); dosbox MAKE.BAT -exit -c "MOUNT D \"../../masm" -c "PATH D:;Z:"

ide_xtp.bin: $(XUB_DIR)/Build/ide_xtp.bin
	cp $< $@

ide_xt.bin: $(XUB_DIR)/Build/ide_xt.bin
	cp $< $@

bios8088.bin: $(BIOS_8088_DIR)/bios.bin
	cp $< $@

glabios.bin: $(GLABIOS_DIR)/GLABIOS.ROM
	cp $< $@

clean:
	@-rm -f bios8088.bin ide_xt.bin ide_xtp.bin
	@-make -s -C $(BIOS_8088_DIR) clean
	@-rm -f $(XUB_DIR)/Build/*
	@-rm -f $(GLABIOS_DIR)/GLABIOS.ROM $(GLABIOS_DIR)/GLABIOS.OBJ $(GLABIOS_DIR)/GLABIOS.EXE