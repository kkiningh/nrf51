# SDK & Softdevice
#SDK_VERSION := 9.0.0
#SD_VERSION  := s110

# Source files
SRCFILES += ./lib/nRF51_SDK_v9.0.0/components/toolchain/gcc/gcc_startup_nrf51.s
SRCFILES += ./lib/nRF51_SDK_v9.0.0/components/toolchain/system_nrf51.c
SRCFILES += src/test.c

INCPATHS += ./lib/nRF51_SDK_v9.0.0/components/device
INCPATHS += ./lib/nRF51_SDK_v9.0.0/components/toolchain
INCPATHS += ./lib/nRF51_SDK_v9.0.0/components/toolchain/gcc
INCPATHS += ./lib/nRF51_SDK_v9.0.0/components/libraries/util

# Output
TARGET := test.bin

# Project specific flags
ASMFLAGS += -D__HEAP_SIZE=0
CPPFLAGS += -DNRF51

-include mk/Makefile.mk
