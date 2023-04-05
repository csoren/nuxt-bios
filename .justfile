BIOS_8088 := "8088_bios"
XUB := "xub"
XUB_EXISTS := path_exists(XUB)
GLABIOS := "glabios/src"

@init:
    if ! {{XUB_EXISTS}}; then \
        svn checkout https://www.xtideuniversalbios.org/svn/xtideuniversalbios/trunk/ {{XUB}}; \
    fi

@update: init
    svn update {{XUB}}
    cd {{BIOS_8088}}; git checkout master; git pull --rebase

@build-modules:
    cd {{BIOS_8088}}; make bios.bin
    cd {{XUB}}/XTIDE_Universal_BIOS; make AS=nasm xtplus xt
    cd {{GLABIOS}}; dosbox MAKE.BAT -exit -c "MOUNT D \"../../masm" -c "PATH D:;Z:"
