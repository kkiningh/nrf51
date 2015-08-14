# SDK
ifdef SDK_VERSION
SDK_PATH          ?= ./lib/nRF51_SDK_v$(SDK_VERSION)
SDK_INCLUDE_PATH  := $(SDK_PATH)/components
SDK_SOURCE_PATH   := $(SDK_PATH)/components
SDK_GCC_PATH      := $(SDK_PATH)/components/toolchain/gcc
endif

# Softdevice
ifdef SD_VERSION
# Use a friendly default for the SD_PATH if we know we're using the SDK
ifdef SDK_VERSION
SD_PATH           ?= $(SDK_PATH)/components/softdevice/$(SD_VERSION)
endif
SD_GCC_PATH       := $(SD_PATH)/toolchain/armgcc
endif

# Varient

# If we're using the softdevice, add the startup file
ifdef SDK_VERSION
SRCFILES += $(SDK_GCC_PATH)/gcc_startup_nrf51.s
SRCFILES += $(SDK_GCC_PATH)/../system_nrf51.c
endif

ifdef SD_VERSION
LDFLAGS  += -L$(SD_GCC_PATH)
LDSCRIPT ?= $(SD_GCC_PATH)/armgcc_$(SD_VERSION)_nrf51822_$(NRF_VARIENT).ld
endif

# If we need the SDK, download it
ifdef SDK_VERSION
$(SDK_PATH):
	$(Q)scripts/nrf51-sdk.sh $(SDK_VERSION) lib
endif

