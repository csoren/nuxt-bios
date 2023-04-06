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

    cd {{GLATICK}}; sed -i 's/^SHOW_BANNER.*=.*/SHOW_BANNER=1/g' GLATICK.ASM
    cd {{GLATICK}}; sed -i 's/^.*RTC_AT.*EQU.*/RTC_AT EQU 1/g' RTC.INC
    cd {{GLATICK}}; sed -i 's/^.*RTC_OK.*EQU.*/;RTC_OK EQU 2/g' RTC.INC
    cd {{GLATICK}}; sed -i 's/^.*RTC_RP.*EQU.*/;RTC_RP EQU 3/g' RTC.INC
    
    if ! {{XUB_EXISTS}}; then \
        svn checkout https://www.xtideuniversalbios.org/svn/xtideuniversalbios/trunk/ {{XUB}}; \
    fi

# Update the XT-IDE Universal BIOS to the latest revision
@update-xub:
    svn update {{XUB}}

# Build all modules
@build-modules:
    make modules

# Build the BIOS'es
@build-bios:
    make bios-nuxt-v20-micro-glabios.bin

# Remove build artifacts
@clean:
    make clean