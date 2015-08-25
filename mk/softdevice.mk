# Softdevice
ifdef SD_VERSION

# Use a friendly default for the SD_PATH if we know we're using the SDK
ifdef SDK_VERSION
SD_PATH  ?= $(SDK_PATH)/components/softdevice/$(SD_VERSION)
endif

ifndef SD_PATH
  $(error "SD_PATH must be defined if we aren't using the SDK")
endif

# Make sure we don't have any trailing whitespace at the end of SD_VERSION
# See http://stackoverflow.com/questions/9116283/trailing-whitespace-in-makefile-variable
# for why this is a problem
ifneq ($(word 2,[$(SD_PATH)]),)
  $(error "There is whitespace inside the value of 'SD_PATH'")
endif

# Add the softdevice header file directory
SYS_INCS += $(SD_PATH)/headers/

# Use the softdevice linker script if there isn't one already
LDSCRIPT ?= $(SD_PATH)/toolchain/armgcc/armgcc_$(SD_VERSION)_nrf51822_$(NRF_VARIENT).ld

endif
