# About
This repository contains scripts, patches and build recipes for building a custom BIOS for the Monotech NuXT modern PC XT compatible system.

It aggregates the [Micro 8088 BIOS](https://github.com/skiselev/8088_bios), [XT-IDE Universal BIOS](https://www.xtideuniversalbios.org/), [GLaBIOS](https://github.com/640-KB/GLaBIOS), [GLaTICK](https://github.com/640-KB/GLaTICK) and [Multi-Floppy](https://github.com/skiselev/floppy_bios) in order to build a hybrid BIOS consisting of two separate BIOS implementations - the first half is a Micro 8088 BIOS + XT-IDE, the second half is GLaBIOS, GLaTICK, Multi-Floppy and XT-IDE which provides the same functionality albeit in a different way. The user may then switch between these two by the use of DIP switch 4 on the NuXT motherboard.

# Prequisites

`svn` and `dosbox` must be available to run from the command line.

On Ubuntu this can be done with apt:
`sudo apt install subversion dosbox`

To use the helper scripts (not mandatory but makes things easier), `just` must be installed. It is often found in your distribution's package manager, but if it isn't you may need to follow specific instructions in [just's repository](https://github.com/casey/just). If `just` is not installed, consult the `.justfile` and find the relevant recipe when needed.

# Setting up

After first cloning the project, perform `just init` to retrieve all submodules and dependencies.

# Building

All BIOS'es may be built by issuing `just build-bios`. Alternatively a single BIOS can be built by using make.

To build a 8088 compatible BIOS: `make bios-nuxt-8088-micro-glabios.bin`

To build a V20 optimized BIOS: `make bios-nuxt-v20-micro-glabios.bin`

# Implementation notes

## Micro 8088
The Micro 8088 BIOS requires nothing special, it is built and used as-is on the NuXT.

## Multi-Floppy
The Multi-Floppy option ROM requires nothing special, it is built and used as-is on the NuXT.

## XT-IDE Universal BIOS
To build on Linux the `AS` variable is passed to `make` as `AS=nasm`.

To build the V20 optimized option `USE_NEC_V=1` is passed to `make`.

## GLaBIOS
GLaBIOS is built using `masm` 6.11, this is included in the `masm` directory. DOSBox is used to do the build.

Two DOS `.BAT` files are used to control the build process, `GBN8.BAT` (for (G)La(B)IOS (N)uXT (8)088) passes `/DARCH_TYPE='F' /DCPU_TYPE='8'` to `masm` for targeting Faraday FE2010A and 8088. `GBNV.BAT` (for (G)La(B)IOS (N)uXT (V)20) passes `/DARCH_TYPE='F' /DCPU_TYPE='V'` to target V20 instead. In `Makefile` `GLABIOS.ASM` is further patched and stored in `GLANUXT.ASM` to target the Micro 8088 platform specifically.

## GLaTICK
GLaTICK is also built using `masm` 6.11 through DOSBox.

GLaTICK is patched to target NuXT hardware in `.justfile` as part of the `init` recipe.

