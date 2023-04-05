BIOS_8088 := "8088_bios"
XUB := "xub"
XUB_EXISTS := path_exists(XUB)
GLABIOS := "glabios/src"

# Show all recipes
@_default:
	just --list

# Initialize the directory after first cloning
@init:
    if ! {{XUB_EXISTS}}; then \
        svn checkout https://www.xtideuniversalbios.org/svn/xtideuniversalbios/trunk/ {{XUB}}; \
    fi

# Update the XT-IDE Universal BIOS to the latest revision
@update-xub: init
    svn update {{XUB}}

# Build the BIOS'es and modules
@build-modules:
    make ide_xt.bin ide_xtp.bin bios8088.bin glabios.bin

# Remove build artifacts
@clean:
    make clean