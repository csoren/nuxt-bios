XUB := "xub"
GLABIOS := "glabios/src"
GLATICK := "glatick/src"
XUB_EXISTS := path_exists(XUB)

# Show all recipes
@_default:
	just --list

# Initialize the directory after first cloning
@init:
    git submodule init
    git submodule update
    if ! {{XUB_EXISTS}}; then \
        svn checkout -r 625 https://www.xtideuniversalbios.org/svn/xtideuniversalbios/trunk/ {{XUB}}; \
    fi
    

# Update the XT-IDE Universal BIOS to the latest revision
@update-xub:
    svn update {{XUB}}

# Build all modules
@build-modules:
    make modules

# Build the BIOS'es
@build-bios:
    make -j bios-nuxt-v20-micro-glabios.bin bios-nuxt-8088-micro-glabios.bin

# Remove build artifacts
@clean:
    make clean

@_flash-test: build-bios
    minipro -w bios-nuxt-v20-micro-glabios.bin -p SST39SF010A
