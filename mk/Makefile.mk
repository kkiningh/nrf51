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
#                 no SDK files will be added to your project. Note this must
#                 be a valid SDK version >= 7.0.0 in the form "X.X.0"
#   SD_VERSION  - The version of the softdevice you require. If you leave this
#                 blank, no softdevice files will be added to your project.
#                 Note that this must be a valid softdevice in the form sXX0
#   NRF_VARIENT - The nrf51 package varient you are building for. This defaults
#                 to xxaa (256kB flash, 16kB RAM). See the "nRF51 Series
#                 Compatibility Matrix" from Nordic for more information
#
####

# Toolchain
PREFIX  ?= arm-none-eabi

AR      := "$(PREFIX)-ar"
AS      := "$(PREFIX)-gcc"
CC      := "$(PREFIX)-gcc"
CXX     := "$(PREFIX)-g++"
GDB     := "$(PREFIX)-gdb"
LD      := "$(PREFIX)-gcc"
OBJCOPY := "$(PREFIX)-objcopy"
OBJDUMP := "$(PREFIX)-objdump"
SIZE    := "$(PREFIX)-size"

# Get the object files we need to compile
OBJFILES := $(patsubst %.s,%.o,$(filter %.s,$(SRCFILES)))
OBJFILES += $(patsubst %.S,%.o,$(filter %.S,$(SRCFILES)))
OBJFILES += $(patsubst %.c,%.o,$(filter %.c,$(SRCFILES)))
OBJFILES += $(patsubst %.cpp,%.o,$(filter %.cpp,$(SRCFILES)))
OBJFILES += $(patsubst %.cxx,%.o,$(filter %.cxx,$(SRCFILES)))

# Get the dependency files
DEPFILES := $(patsubst %.o,%.d,$(OBJFILES))

# Set architecture specific flags
CPU ?= cortex-m0

ARCH_FLAGS += -mcpu=$(CPU) -mthumb  # Generate code for the correct processor
ARCH_FLAGS += -mabi=aapcs           # Use the most modern ARM abi
ARCH_FLAGS += -msoft-float          # Use libgcc to emulate floating point

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
CFLAGS  += -Winline               # Unable to inline function marked inline
CFLAGS  += -Wmissing-declarations # Global functions must be declared before use
CFLAGS  += -Wmissing-prototypes   # Same as above, but for prototypes
CFLAGS  += -Wstrict-prototypes    # Functions must declare their parameter types
CFLAGS  += -std=c99 -pedantic     # Use C99

CFLAGS  += -ffunction-sections    # Generate seperate section for each function
CFLAGS  += -fdata-sections        # Same as above, but for global variables
CFLAGS  += -fno-strict-aliasing   # Do not assume strict aliasing

CFLAGS  += $(patsubst %,-I%,$(INCPATHS))        # Add project includes
CFLAGS  += $(patsubst %,-isystem%,$(SYS_INCS))  # Add system includes

# Disable annoying warnings
# CFLAGS +=

# Set linker options
NRF_VARIENT ?= xxaa

LDSCRIPT ?= ./ld/nrf51_$(NRF_VARIENT).ld

LDFLAGS += -L./ld/
LDFLAGS += -Wl,--gc-sections      # Allow the linker to remove unused sections
LDFLAGS += -Wl,-Map=$*.map        # Create a map file
LDFLAGS += --specs=nano.specs -lc -lnosys # Use newlib nano as C stdlib

# Set assembler options
ASMFLAGS += -x assembler-with-cpp # Use the preprocessor when assembling files

# Set preprocessor flags
CPPFLAGS += -Wall -Wundef         # Turn on all preprocessor warnings
CPPFLAGS += -MD                   # Generate dependency information

# Remove the default suffix rules
.SUFFIXES:

# Set the phony targets (i.e. the targets that should not produce a file)
.PHONY: debug release clean

#OUTDIR = build/$(shell echo "$(strip $(CFLAGS) $(LDFLAGS) $(CPPFLAGS) $(ARCH_FLAGS))" | sha1sum)
OUTDIR ?= build

__dummy := $(shell mkdir -p $(OUTDIR))

debug: CFLAGS += -g -O0
debug: CPPFLAGS += -DDEBUG
debug: $(OUTDIR)/$(TARGET)

release: CFLAGS += -Os
release: CPPFLAGS += -DNDEBUG
release: $(OUTDIR)/$(TARGET)

clean:
	-$(RM) $(OBJFILES) $(DEPFILES) $(TARGET)

# Quiet by default, use V=1 to show executed commands
ifneq ($(V),1)
Q := @
endif

# Common targets
$(OUTDIR)/%.o: %.s
	@echo "  AS      $@"
	@mkdir -p $(dir $@)
	$(Q)$(AS) $(ASFLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(OUTDIR)/%.o: %.S
	@echo "  AS      $@"
	@mkdir -p $(dir $@)
	$(Q)$(AS) $(ASFLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(OUTDIR)/%.o: %.c
	@echo "  CC      $@"
	@mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) $(INC_FLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(OUTDIR)/%.o: $%.cpp
	@echo "  CXX     $@"
	@mkdir -p $(dir $@)
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(OUTDIR)/%.o: %.cxx
	@echo "  CXX     $@"
	mkdir -p $(dir $@)
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(OUTDIR)/%.bin: $(OUTDIR)/%.elf
	@echo "  OBJDUMP $@"
	$(Q)$(OBJCOPY) -Obinary $< $@

$(OUTDIR)/%.hex: $(OUTDIR)/%.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY) -Oihex $< $@

$(OUTDIR)/%.srec: $(OUTDIR)/%.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY) -Osrec $< $@

$(OUTDIR)/%.list: $(OUTDIR)/%.elf
	@echo "  OBJDUMP $@"
	$(Q)$(OBJDUMP) -S $< > $@

$(OUTDIR)/%.elf: $(addprefix $(OUTDIR)/,$(OBJFILES)) $(LDSCRIPT)
	@echo "  LD      $@"
	@echo $^
	$(Q)$(LD) $(LDFLAGS) -T$(LDSCRIPT) $(ARCH_FLAGS) -o $@ $(addprefix $(OUTDIR)/,$(OBJFILES))

# Include dependency files for incremental builds
-include $(DEPFILES)
