# About
This repository contains scripts, patches and build recipes for building a custom BIOS from source for the Monotech NuXT V1 modern PC XT compatible system. It will currently *not* work on V2. If you would like to help, please look at [this issue](https://github.com/csoren/nuxt-bios/issues/2).

It aggregates the [Micro 8088 BIOS](https://github.com/skiselev/8088_bios), [XT-IDE Universal BIOS](https://www.xtideuniversalbios.org/), [GLaBIOS](https://github.com/640-KB/GLaBIOS), [GLaTICK](https://github.com/640-KB/GLaTICK), [Multi-Floppy](https://github.com/skiselev/floppy_bios) and [IBM Cassette BASIC](https://en.wikipedia.org/wiki/IBM_BASIC) in order to build a hybrid BIOS consisting of two separate BIOS implementations.

The hybrid BIOS is a 128 KiB image suitable for flashing onto the BIOS EEPROM. The user may select one of the two BIOS'es before booting the machine by the use of DIP switch 4 on the NuXT motherboard.

The first BIOS is active when the switch is OFF, it consists of the Micro 8088 BIOS + XT-IDE for booting the CF Card. The Micro 8088 BIOS supports RTC and all types of floppy drives out of the box. This BIOS does not support IBM BASIC.

The second BIOS is active when the switch is ON, this BIOS is based on GLaBIOS. GLaBIOS relies on option ROM's to provide certain functionality, so this half includes GLaTICK (for RTC support), Multi-Floppy (for supporting drives other than 360 KiB) and XT-IDE (for booting from CF Card). This is essentially the same functionality albeit in a different way. This BIOS includes IBM BASIC so `BASICA.COM` will work.

Current versions of the different modules are:

|Module|Version|
|---|---|
|Micro 8088|v0.9.9|
|GLaBIOS|v0.2.4|
|XT-IDE Universal BIOS|r625|


# Downloading

The BIOS images can either be built from source by following the instructions below, or downloaded from the [releases page](https://github.com/csoren/nuxt-bios/releases).

# Building

## Prequisites

`svn` and `dosbox` must be available to run from the command line.

On Ubuntu this can be done with apt:
`sudo apt install subversion dosbox`

To use the helper scripts (not mandatory but makes things easier), `just` must be installed. It is often found in your distribution's package manager, but if it isn't you may need to follow specific instructions in [just's repository](https://github.com/casey/just). If `just` is not installed, consult the `.justfile` and find the relevant recipe when needed.

## Setting up

After first cloning the project, perform `just init` to retrieve all submodules and dependencies.

## Building

All BIOS'es may be built by issuing `just build` (or `make -j`). Alternatively a single BIOS can be built by using `make`.

Micro 8088 builds contain the Micro 8088 main BIOS + XT-IDE.

GLaBIOS builds contain the main GLaBIOS BIOS and XT-IDE + Multi-Floppy + GLaTICK + BASIC.

"Hybrid" builds are 128 KiB images suitable for replacing the whole EEPROM content, other builds can be used to write each EEPROM half independently or to create other "hybrids".

Artifacts built are:

| Name | Content | Size |
|-|-|-|
|`bios-nuxt-hybrid-universal.bin`|Hybrid universal|128 KiB|
|`bios-nuxt-hybrid-V20.bin`|Hybrid V20 optimized|128 KiB|
|`bios-nuxt-glabios-universal.bin`|GLaBIOS universal|64 KiB|
|`bios-nuxt-glabios-v20.bin`|GLaBIOS V20 optimized|64 KiB|
|`bios-nuxt-micro-universal.bin`|Micro 8088 universal 8088|64 KiB|
|`bios-nuxt-micro-v20.bin`|GLaBIOS V20 optimized|64 KiB|

# Implementation notes

## Micro 8088
The Micro 8088 BIOS requires nothing special, it is built and used as-is on the NuXT.

## Multi-Floppy
The Multi-Floppy option ROM requires nothing special, it is built and used as-is on the NuXT.

## XT-IDE Universal BIOS
To build on Linux the `AS` variable is passed to `make` as `AS=nasm`.

To build the V20 optimized option `USE_NEC_V=1` is passed to `make`.

## GLaBIOS
GLaBIOS is built using `masm` 5.0, this is included in the `masm5` directory. DOSBox is used to do the build.

Two DOS `.BAT` files are used to control the build process, `GBN8.BAT` (for (G)La(B)IOS (N)uXT (8)088) passes `/DARCH_TYPE='F' /DCPU_TYPE='8'` to `masm` for targeting Faraday FE2010A and 8088. `GBNV.BAT` (for (G)La(B)IOS (N)uXT (V)20) passes `/DARCH_TYPE='F' /DCPU_TYPE='V'` to target V20 instead.

## GLaTICK
GLaTICK is also built using `masm` 5.0 through DOSBox.

GLaTICK is patched to target common NuXT hardware RTC's in `Makefile` using the `rtc.patch` file.

