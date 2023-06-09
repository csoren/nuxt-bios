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
    make -j modules

# Build the BIOS'es
@build:
    make -j all

# Remove build artifacts
@clean:
    make clean

@release xub glabios micro8088: clean build
    gh release create xub-{{xub}}_glabios-{{glabios}}_micro8088-{{micro8088}} --notes XT-IDE\ Universal\ BIOS\ {{xub}},\ GLaBIOS\ {{glabios}},\ Micro\ 8088\ {{micro8088}} bios-*.bin

@_flash-test: build
    minipro -w bios-nuxt-hybrid-v20.bin -p SST39SF010A
