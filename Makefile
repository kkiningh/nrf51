# First target is default
.PHONY: all
all: debug

# Project
TARGET   := test.bin          # Output file
SRC      += src/test.c        # Source files
INC      += src               # Include Directories

# SDK
SDK_VERSION := 11.0.0
SDK_PATH    := lib/nRF51_SDK_v$(SDK_VERSION)
SDK_SRC     +=                # SDK source files
SDK_INC     +=                # SDK header directories

# Softdevice
SD_VERSION  := s130

# Project specific flags
ASMFLAGS += -D__HEAP_SIZE=0   # Don't use any heap

include mk/sdk.mk
include mk/softdevice.mk
include mk/Makefile.mk
