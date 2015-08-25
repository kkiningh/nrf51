###
# sdk-auto.mk
#
# If SDK_VERSION is defined, that version is downloaded automatically from the
# Nordic website.
#
###
ifdef SDK_VERSION

# SDK path defaults to the lib directory
SDK_PATH ?= lib/nRF51_SDK_v$(SDK_VERSION)
SDK_ZIP  := $(SDK_PATH).zip
SDK_MK   := $(SDK_PATH).mk

# Download the SDK if we don't already have it
$(SDK_ZIP):
	@echo "Downloading SDK $(SDK_VERSION)"
	$(Q)mkdir -p "$(dir $@)"
	$(Q)scripts/sdk.sh "$(SDK_VERSION)" "$@"

$(SDK_PATH): $(SDK_ZIP)
	$(Q)unzip -qq -o -d $@ $<
	$(Q)find $@ -print0 | xargs -0 touch -r $@

# Generate the file list for the SDK
$(SDK_MK): $(SDK_ZIP)
	$(Q)unzip -l -qq $< | awk '{print "$$(SDK_PATH)/"$$4" \\"}' | sort | uniq > $@
	$(Q)printf ': $$(SDK_PATH)' >> $@

-include $(SDK_MK)

endif

###
# sdk.mk
#
# If SDK_PATH is defined, automatically include important SDK source files
#
###
ifdef SDK_PATH

# Make sure we don't have any trailing whitespace at the end of SDK_VERSION
# See http://stackoverflow.com/questions/9116283/trailing-whitespace-in-makefile-variable
ifneq ($(word 2,[$(SDK_PATH)]),)
  $(error "There is whitespace inside the value of 'SDK_PATH'")
endif

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

# Add the SDK files we need to the list of files to compile
SRC     += $(SDK_SRC)
SYS_INC += $(SDK_INC)

endif
