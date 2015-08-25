####
# Makefile.mk - Helper file for projects depending on the nRF51 SDK
#
# You can include this file by adding
#   include mk/Makefile.mk
# to the bottom of your makefile
#
# To use this makefile you must define these variables:
#   TARGET  - The name of the binary you want to produce
#   SRC     - Your project's source files
#   INC     - Your project's include directories
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

# Set the build folder
OUTDIR        ?= build
OUTDIR_TARGET := $(addprefix $(OUTDIR)/, $(TARGET))

# Get the object files we need to compile
define MKOBJ
$(addprefix $(OUTDIR)/,$(patsubst %$1,%.o,$(filter %$1,$2)))
endef

OBJ += $(call MKOBJ,.s,  $(SRC))
OBJ += $(call MKOBJ,.S,  $(SRC))
OBJ += $(call MKOBJ,.c,  $(SRC))
OBJ += $(call MKOBJ,.cpp,$(SRC))
OBJ += $(call MKOBJ,.cxx,$(SRC))

# Get the dependency files
DEP += $(patsubst %.o,%.d,$(OBJ))

# Set architecture specific flags
ARCH_FLAGS += -mcpu=cortex-m0     # Generate code for the cortex-m0
ARCH_FLAGS += -mthumb             # Generate only thumb instructions
ARCH_FLAGS += -mabi=aapcs         # Use the most modern ARM abi
ARCH_FLAGS += -msoft-float        # Use libgcc to emulate floating point

TARGET_ARCH ?= $(strip $(ARCH_FLAGS))

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

CFLAGS  += $(patsubst %,-I%,$(INC))           # Project header
CFLAGS  += $(patsubst %,-isystem%,$(SYS_INC)) # System includes

# Set linker options
NRF_VARIENT ?= xxaa

LDSCRIPT ?= ./ld/nrf51_$(NRF_VARIENT).ld

LDFLAGS += -L./ld/
LDFLAGS += -Wl,--gc-sections      # Allow the linker to remove unused sections
LDFLAGS += --specs=nano.specs -lc -lnosys # Use newlib nano as C stdlib

# Set assembler options
ASMFLAGS += -x assembler-with-cpp # Use the preprocessor when assembling files

# Set preprocessor flags
CPPFLAGS += -Wall -Wundef         # Turn on all preprocessor warnings
CPPFLAGS += -MD -MP               # Generate dependency information

# Remove the default suffix rules
.SUFFIXES:

# Never remove targets, even if they're considered intermediate
.SECONDARY:

# Set the phony targets (i.e. the targets that should not produce a file)
.PHONY: debug release clean

# Quiet by default, use V=1 to show executed commands
ifneq ($(V),1)
Q := @
endif

debug: CFLAGS += -g -O0
debug: CPPFLAGS += -DDEBUG
debug: $(OUTDIR_TARGET)

release: CFLAGS += -Os
release: CPPFLAGS += -DNDEBUG
release: $(OUTDIR_TARGET)

clean:
	-$(RM) $(OBJ) $(DEP) $(OUTDIR_TARGET)
	-$(RM) $(addsuffix .elf,$(basename $(OUTDIR_TARGET)))
	-$(RM) $(addsuffix .map,$(basename $(OUTDIR_TARGET)))

# Common targets
%.bin: %.elf
	@echo "  OBJDUMP $@"
	$(Q)$(OBJCOPY) -Obinary $< $@

%.hex: %.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY) -Oihex $< $@

%.srec: %.elf
	@echo "  OBJCOPY $@"
	$(Q)$(OBJCOPY) -Osrec $< $@

%.list: %.elf
	@echo "  OBJDUMP $@"
	$(Q)$(OBJDUMP) -S $< > $@

%.elf %.map: $(OBJ) $(LDSCRIPT)
	@echo "  LD      $@"
	$(Q)$(LD) $(LDFLAGS) -T$(LDSCRIPT) -Wl,-Map=$*.map $(TARGET_ARCH) -o $*.elf $(OBJ)

$(OUTDIR)/%.o: %.s
	@echo "  AS      $@"
	@mkdir -p $(dir $@)
	$(Q)$(AS) $(ASFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -o $@ -c $<

$(OUTDIR)/%.o: %.S
	@echo "  AS      $@"
	@mkdir -p $(dir $@)
	$(Q)$(AS) $(ASFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -o $@ -c $<

$(OUTDIR)/%.o: %.c
	@echo "  CC      $@"
	@mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -o $@ -c $<

$(OUTDIR)/%.o: %.cpp
	@echo "  CXX     $@"
	@mkdir -p $(dir $@)
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -o $@ -c $<

$(OUTDIR)/%.o: %.cxx
	@echo "  CXX     $@"
	@mkdir -p $(dir $@)
	$(Q)$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -o $@ -c $<

# Include dependency files for incremental builds
-include $(DEP)
