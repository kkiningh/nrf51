# SDK
ifdef SDK_VERSION

# Make sure we don't have any trailing whitespace at the end of SDK_VERSION
# See http://stackoverflow.com/questions/9116283/trailing-whitespace-in-makefile-variable
# for why this is a problem
ifneq ($(word 2,[$(SDK_VERSION)]),)
  $(error There is a whitespace inside the value of 'SDK_VERSION')
endif

# SDK path defaults to the lib directory
SDK_PATH ?= lib/nRF51_SDK_v$(SDK_VERSION)

# Add the startup files
SRCFILES += $(SDK_PATH)/components/toolchain/gcc/gcc_startup_nrf51.s
SRCFILES += $(SDK_PATH)/components/toolchain/system_nrf51.c

# Add common header file directories
SYS_INCS += $(SDK_PATH)/components/device
SYS_INCS += $(SDK_PATH)/components/libraries/util
SYS_INCS += $(SDK_PATH)/components/toolchain
SYS_INCS += $(SDK_PATH)/components/toolchain/gcc

# Add required defines for the SDK
CPPFLAGS += -DNRF51       # Required for nrf.h

# Download the SDK if we don't already have it
#$(SDK_PATH)/%:
#	@echo "Installing SDK v$(SDK_VERSION)"
#	$(Q)scripts/nrf51-sdk.sh $(SDK_VERSION) lib

endif
