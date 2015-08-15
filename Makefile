# First target is default
.PHONY: all
all: debug

# Project
TARGET   := test.bin          # Output file
SRCFILES += src/test.c        # Source files
INCPATHS += src               # Include Directories

# SDK
SDK_VERSION := 9.0.0
SRCFILES +=                   # SDK source files
SYS_INCS +=                   # SDK header directories

# Softdevice
SD_VERSION  := s110

# Project specific flags
ASMFLAGS += -D__HEAP_SIZE=0   # Don't use any heap

include mk/sdk.mk
include mk/softdevice.mk
include mk/Makefile.mk
