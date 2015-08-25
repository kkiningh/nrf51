ifdef SDK_VERSION

# Make sure we don't have any trailing whitespace at the end of SDK_VERSION
# See http://stackoverflow.com/questions/9116283/trailing-whitespace-in-makefile-variable
ifneq ($(word 2,[$(SDK_VERSION)]),)
  $(error "There is whitespace inside the value of 'SDK_VERSION'")
endif

# SDK path defaults to the lib directory
SDK_PATH ?= lib/nRF51_SDK_v$(SDK_VERSION)
SDK_ZIP  := $(SDK_PATH).zip
SDK_URL  := https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v9.x.x/nRF51_SDK_9.0.0_2e23562.zip

# Add required startup files
SDK_SRC  += $(SDK_PATH)/components/toolchain/gcc/gcc_startup_nrf51.s
SDK_SRC  += $(SDK_PATH)/components/toolchain/system_nrf51.c

# Add common header file directories
SDK_INC  += $(SDK_PATH)/components/device
SDK_INC  += $(SDK_PATH)/components/libraries/util
SDK_INC  += $(SDK_PATH)/components/toolchain
SDK_INC  += $(SDK_PATH)/components/toolchain/gcc

# Add required defines for the SDK
CPPFLAGS += -DNRF51       # Required for nrf.h

# Download the SDK if we don't already have it
$(SDK_ZIP):
	$(Q)curl $(SDK_URL) --progress-bar -o "$@"

$(addprefix $(SDK_PATH)/,$(shell cat "mk/sdk/$(SDK_VERSION)")): $(SDK_ZIP)
	$(Q)unzip -qq -o -d $(SDK_PATH) $(SDK_ZIP)
	$(Q)find $(SDK_PATH) -print0 | xargs -0 touch -r $(SDK_PATH)

# Add the SDK files we need to the list of files to compile
SRC     += $(SDK_SRC)
SYS_INC += $(SDK_INC)

endif
