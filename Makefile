####
# Makefile.include - Helper file for projects depending on the nRF51 SDK
#
# You can include this file by adding
#   -include Makefile.include
# to the bottom of your makefile
#
# You must define these variables
#   TARGET   - The name of the binary you want to produce
#   SRCFILES - Your project's source files
#   INCFILES - Your project's include files. Note that if you define
#              SDK_VERSION, all sdk header files are already added to
#              your project
#
# You may optionally define these variables
#   SDK_VERSION - The version of the SDK you require. If you leave this blank,
#                 no SDK files will be added to your project
#
####

# SDK
ifdef SDK_VERSION
SDK_PATH          := ./nRF51_SDK/$(SDK_VERSION)
SDK_INCLUDE_PATH  := $(SDK_PATH)/Include
SDK_SOURCE_PATH   := $(SDK_PATH)/Source
SDK_TEMPLATE_PATH := $(SDK_PATH)/Source/templates/gcc
endif

# Executables
PREFIX  ?= /usr/bin/arm-none-eabi

AR      := "$(PREFIX)-ar"
AS      := "$(PREFIX)-as"
CC      := "$(PREFIX)-gcc"
CXX     := "$(PREFIX)-g++"
GDB     := "$(PREFIX)-gdb"
LD      := "$(PREFIX)-gcc"
OBJCOPY := "$(PREFIX)-objcopy"
OBJDUMP := "$(PREFIX)-objdump"

# Get the object files we need to compile
OBJFILES := $(patsubst %.c,%.o,$(SRCFILES))

# Dependency tracking for incremental builds
DEPFILES := $(patsubst %.c,%.d,$(SRCFILES))

# Set the CPU type
CPU ?= cortex-m0

ARCH_FLAGS += -mcpu=$(CPU) -mthumb -mabi=aapcs -msoft-float

# Set compiler options
CFLAGS  += -Wall -Wextra -Werror  # Standard warnings
CFLAGS  += -Wformat=2             # Common format string errors
CFLAGS  += -Wshadow               # No redeclaration of variables
CFLAGS  += -Wpointer-arith        # No pointer arithmatic on void*
CFLAGS  += -Wcast-align           # A cast should not change alignment
CFLAGS  += -Wconversion           # Implicit converstion should not change value
CFLAGS  += -Wwrite-strings        # String literals are const
CFLAGS  += -Wnested-externs       # No using extern for local variables
CFLAGS  += -Wredundant-decls      # No unneccessary redeclaration
CFLAGS  += -Winline							  # Unable to inline function marked inline
CFLAGS  += -Wmissing-declarations # Global functions must be declared before use
CFLAGS  += -Wmissing-prototypes   # Same as above, but for prototypes
CFLAGS  += -Wstrict-prototypes    # Functions must declare their parameter types
CFLAGS  += -std=c99 -pedantic     # Use C99

CFLAGS  += -ffunction-sections    # Generate seperate section for each function
CFLAGS  += -fdata-sections        # Same as above, but for global variables

# Disable annoying warnings
# CFLAGS +=

# Set linker options
LDSCRIPT ?= default.ld

LDFLAGS += -T$(LDSCRIPT)          # Set the linker script
LDFLAGS += -Wl,--gc-sections      # Allow the linker to remove unused sections
LDFLAGS += -Wl,-Map=$(*).map      # Create a map file

ifdef SDK_VERSION
LDFLAGS += -L $(SDK_TEMPLATE_PATH)
endif

# Set assembler options

# Quiet by default, use V=1 to show all steps
ifneq ($(VERBOSE),1)
Q := @
endif

# Remove the default suffix rules
.SUFFIXES:

# Set the phony targets (i.e. the targets that should not produce a file)
.PHONY: debug release clean

# Enable debug information
debug: CLFAGS += -g
debug: $(TARGET)

# Enable aggressive optimization for a release build
release: CFLAGS += -Os -DNDEBUG
release: $(TARGET)

# If we need the SDK, download it using a script
ifdef SDK_VERSION
$(SDK_PATH):
	$(Q)nrf51-sdk.sh $(SDK_VERSION)
endif

%.o: %.c
	$(Q)$(CC) $(CFLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -c $< -o $@

%.bin: %.elf
	$(Q)$(OBJCOPY) -Obinary $< $@

%.hex: %.elf
	$(Q)$(OBJCOPY) -Oihex $< $@

%.srec: %.elf
	$(Q)$(OBJCOPY) -Osrec $< $@

%.list: %.elf
	$(Q)$(OBJDUMP) -S $< > $@

%.elf %.map:
	$(Q)$(LD) $(LDFLAGS) $(ARCH_FLAGS) $(OBJS) $(LDLIBS) -o $*.elf

$(TARGET): $(OBJFILES)

clean:
	$(Q)$(RM) $(wildcard $(OBJFILES) $(DEPFILES) $(TARGET))

# Include dependency files for incremental builds
-include $(DEPFILES)
