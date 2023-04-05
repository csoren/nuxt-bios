BIOS_8088 := "8088_bios"
XUB := "xub"
XUB_EXISTS := path_exists(XUB)

@init:
    if ! {{XUB_EXISTS}}; then \
        svn checkout https://www.xtideuniversalbios.org/svn/xtideuniversalbios/trunk/ {{XUB}}; \
    fi

@update: init
    svn update {{XUB}}
    cd {{BIOS_8088}}; git checkout master; git pull --rebase

@build:
    cd {{BIOS_8088}}; make bios.bin