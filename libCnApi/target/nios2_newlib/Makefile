#------------------------------------------------------------------------------
#              VARIABLES APPENDED TO BY INCLUDED MAKEFILE FRAGMENTS
#------------------------------------------------------------------------------

# List of include directories for -I compiler option (-I added when used).
# Includes the BSP.
ALT_INCLUDE_DIRS := ../../include ../../utils

# Define path to the root of the BSP.
BSP_ROOT_DIR := ../../../powerlink/EBV_DBC3C40_DPRAM/bsp


# List of root library directories that support running make to build them.
# Includes the BSP and any ALT libraries.
MAKEABLE_LIBRARY_ROOT_DIRS :=

# Generic flags passed to the compiler for different types of input files.
ALT_CFLAGS :=
ALT_CXXFLAGS :=
ALT_CPPFLAGS :=
ALT_ASFLAGS :=
ALT_ARFLAGS :=

#------------------------------------------------------------------------------
#                                 TOOLS
#------------------------------------------------------------------------------
CROSS_COMPILE := nios2-elf-
CC      := $(CROSS_COMPILE)gcc -xc
CXX     := $(CROSS_COMPILE)gcc -xc++
AS      := $(CROSS_COMPILE)gcc
AR      := $(CROSS_COMPILE)ar
LD      := $(CROSS_COMPILE)g++
NM      := $(CROSS_COMPILE)nm
RM      := rm -f
OBJDUMP := $(CROSS_COMPILE)objdump
OBJCOPY := $(CROSS_COMPILE)objcopy
STACKREPORT := nios2-stackreport

MKDIR := mkdir -p
ECHO := echo


#------------------------------------------------------------------------------
#                         The adjust-path macro
# 
# If COMSPEC is defined, Make is launched from Windows through
# Cygwin.  This adjust-path macro will call 'cygpath -u' on all
# paths to ensure they are readable by Make.
#
# If COMSPEC is not defined, Make is launched from *nix, and no adjustment
# is necessary
#------------------------------------------------------------------------------

ifdef COMSPEC
	adjust-path = $(shell cygpath -u "$1")
	adjust-path-mixed = $(shell cygpath -m "$1")
else
	adjust-path = $1
	adjust-path-mixed = $1
endif

#------------------------------------------------------------------------------
#                           DEFAULT TARGET
#------------------------------------------------------------------------------

# Put "all" rule before included makefile fragments because they may
# define rules and we don't want one of those to become the default rule.
.PHONY : all
all : build_pre_process makeable_libs lib build_post_process

#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#                           GENERATED SETTINGS START                         v
#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#START GENERATED

# The following TYPE comment allows tools to identify the 'type' of target this 
# makefile is associated with. 
# TYPE: LIB_MAKEFILE

# This following VERSION comment indicates the version of the tool used to 
# generate this makefile. A makefile variable is provided for VERSION as well. 
# ACDS_VERSION: 9.1sp2
ACDS_VERSION := 9.1sp2

# This following BUILD_NUMBER comment indicates the build number of the tool 
# used to generate this makefile. 
# BUILD_NUMBER: 350


# The library name (without a "lib" prefix or ".a" suffix).
#
# It may be used by the makefile fragments so is defined before including them.
#
LIB_NAME := CnApi

# Paths to C, C++, and assembly source files.
C_SRCS += ../../src/cnApi.c
C_SRCS += ../../src/cnApiAsync.c
C_SRCS += ../../src/cnApiObjects.c
C_SRCS += ../../src/cnApiPdo.c
C_SRCS += ../../src/cnApiStateMachine.c
C_SRCS += ../../src/cnApiPdiSpi.c
C_SRCS += ../../utils/stateMachine.c
CXX_SRCS :=
ASM_SRCS :=


# Path to root of object file tree.
OBJ_ROOT_DIR := obj

# Common arguments for LIB_CFLAGS
LIB_CFLAGS_DEFINED_SYMBOLS :=
LIB_CFLAGS_UNDEFINED_SYMBOLS :=
LIB_CFLAGS_OPTIMIZATION := -O0
LIB_CFLAGS_DEBUG_LEVEL := -g
LIB_CFLAGS_WARNINGS := -Wall
LIB_CFLAGS_USER_FLAGS := -D_DEBUG -DDEF_DEBUG_LVL=0xEC000700L

LIB_ASFLAGS_USER :=

# Common arguments for LIB_ARCHIVER_FLAGS
LIB_ARCHIVER_FLAGS := -src

# List of library specific include directories
LIB_INCLUDE_DIRS :=

# Pre- and post- processor settings.
BUILD_PRE_PROCESS :=
BUILD_POST_PROCESS :=

# List of public include directories for -I compiler option (-I added when used).


#END GENERATED

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                            GENERATED SETTINGS END                           ^
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#------------------------------------------------------------------------------
#                 VARIABLES DEPENDENT ON GENERATED CONTENT
#------------------------------------------------------------------------------

# Define absolute path to the root of the BSP.

ifneq ($(BSP_ROOT_DIR),)

# Define absolute path to the root of the BSP.
ABS_BSP_ROOT_DIR := $(call adjust-path-mixed,$(shell cd "$(BSP_ROOT_DIR)"; pwd))

# Include makefile fragments.  Define variable ALT_LIBRARY_ROOT_DIR before
# including each makefile fragment so that it knows the path to itself.
BSP_INCLUDE_FILE := $(BSP_ROOT_DIR)/public.mk
ALT_LIBRARY_ROOT_DIR := $(BSP_ROOT_DIR)

include $(BSP_INCLUDE_FILE)
endif


# Library file name 
LIB := lib$(LIB_NAME).a

# Take lists and add required prefixes.
LIB_INC_DIRS := $(addprefix -I, $(ALT_INCLUDE_DIRS) $(LIB_INCLUDE_DIRS) $(INC_DIRS))

# Arguments for the C preprocessor, C/C++ compiler, assembler, and linker.
LIB_CFLAGS := $(LIB_CFLAGS_DEFINED_SYMBOLS) \
              $(LIB_CFLAGS_UNDEFINED_SYMBOLS) \
              $(LIB_CFLAGS_OPTIMIZATION) \
              $(LIB_CFLAGS_DEBUG_LEVEL) \
              $(LIB_CFLAGS_WARNINGS) \
              $(LIB_CFLAGS_USER_FLAGS) \
              $(ALT_CFLAGS) \
              $(CFLAGS)

# Arguments only for the C++ compiler.
LIB_CXXFLAGS := $(ALT_CXXFLAGS) $(CXXFLAGS)

# Arguments only for the C preprocessor.
# Prefix each include directory with -I.
LIB_CPPFLAGS := $(LIB_INC_DIRS) \
                $(ALT_CPPFLAGS) \
                $(CPPFLAGS)

# Arguments only for the assembler.
LIB_ASFLAGS := $(LIB_ASM_INC_DIRS) \
               $(ALT_ASFLAGS) \
               $(LIB_ASFLAGS_USER) \
               $(ASFLAGS)

# Arguments only for the archiver.
LIB_ARFLAGS := $(ALT_ARFLAGS) \
               $(LIB_ARCHIVER_FLAGS)

# Create list of object files to be built using the list of source files.
# The source file hierarchy is preserved in the object tree.
# The supported file extensions are:
#
# .c            - for C files
# .cxx .cc .cpp - for C++ files
# .S .s         - for assembler files
#
# Handle source files specified by --src-dir & --src-rdir differently, to
# save some processing time in calling the adjust-path macro.

OBJ_LIST := $(sort $(C_SRCS:.c=.o)  \
              $(patsubst %.cxx, %.o,                              \
                $(patsubst %.cc, %.o,                             \
                  $(patsubst %.cpp, %.o, $(CXX_SRCS))))           \
              $(patsubst %.S, %.o, $(patsubst %.s, %.o, $(ASM_SRCS))))

SDIR_OBJ_LIST := $(sort $(SDIR_C_SRCS:.c=.o)  \
              $(patsubst %.cxx, %.o,                              \
                $(patsubst %.cc, %.o,                             \
                  $(patsubst %.cpp, %.o, $(SDIR_CXX_SRCS))))           \
              $(patsubst %.S, %.o, $(patsubst %.s, %.o, $(SDIR_ASM_SRCS))))

# Relative-pathed objects that being with "../" are handled differently.
#
# Regular objects are created as 
#   $(OBJ_ROOT_DIR)/<path>/<filename>.o
# where the path structure is maintained under the obj directory.  This
# applies for both absolute and relative paths; in the absolute path
# case this means the entire source path will be recreated under the obj
# directory.  This is done to allow two source files with the same name
# to be included as part of the project.
#
# Note: On Cygwin, the path recreated under the obj directory will be 
# the cygpath -u output path.
#
# Relative-path objects that begin with "../" cause problems under this 
# scheme, as $(OBJ_ROOT_DIR)/../<rest of path>/ can potentially put the object
# files anywhere in the system, creating clutter and polluting the source tree.
# As such, their paths are flattened - the object file created will be 
# $(OBJ_ROOT_DIR)/<filename>.o.  Due to this, two files specified with 
# "../" in the beginning cannot have the same name in the project.  VPATH 
# will be set for these sources to allow make to relocate the source file 
# via %.o rules.
#
# The following lines separate the object list into the flatten and regular
# lists, and then handles them as appropriate.

FLATTEN_OBJ_LIST += $(strip $(foreach s,$(OBJ_LIST),$(if $(filter ../%,$s),$s)))
REGULAR_OBJ_LIST += $(filter-out $(FLATTEN_OBJ_LIST),$(OBJ_LIST))

FLATTEN_LIB_OBJS := $(addprefix $(OBJ_ROOT_DIR)/, \
			$(foreach s,$(FLATTEN_OBJ_LIST),$(notdir $s)))

FLATTEN_SDIR_OBJ_LIST += $(strip $(foreach s,$(SDIR_OBJ_LIST),$(if $(filter ../%,$s),$s)))
REGULAR_SDIR_OBJ_LIST += $(filter-out $(FLATTEN_SDIR_OBJ_LIST),$(SDIR_OBJ_LIST))

FLATTEN_SDIR_LIB_OBJS := $(addprefix $(OBJ_ROOT_DIR)/, \
			$(foreach s,$(FLATTEN_SDIR_OBJ_LIST),$(notdir $s)))

VPATH := $(sort $(dir $(FLATTEN_OBJ_LIST)) $(dir $(FLATTEN_SDIR_OBJ_LIST)))

LIB_OBJS := $(addprefix $(OBJ_ROOT_DIR)/, \
		$(foreach s,$(REGULAR_OBJ_LIST),$(call adjust-path,$s))) \
            $(addprefix $(OBJ_ROOT_DIR)/, \
		$(REGULAR_SDIR_OBJ_LIST)) \
	    $(FLATTEN_LIB_OBJS) $(FLATTEN_SDIR_LIB_OBJS)

# Add any extra user-provided object files.
LIB_OBJS += $(OBJS)

# Create list of dependancy files for each object file.
LIB_DEPS := $(LIB_OBJS:.o=.d)

#------------------------------------------------------------------------------
#                           BUILD PRE/POST PROCESS
#------------------------------------------------------------------------------
build_pre_process :
	$(BUILD_PRE_PROCESS)

build_post_process :
	$(BUILD_POST_PROCESS)

.PHONY: build_pre_process build_post_process

#------------------------------------------------------------------------------
#                     PATTERN RULES TO BUILD OBJECTS
#------------------------------------------------------------------------------

$(OBJ_ROOT_DIR)/%.o: %.c
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CC) -MP -MMD -c $(LIB_CPPFLAGS) $(LIB_CFLAGS) -o $@ $<
	$(CC_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.cpp
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -MP -MMD -c $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<
	$(CXX_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.cc
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -MP -MMD -c $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<
	$(CXX_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.cxx
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -MP -MMD -c $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<
	$(CXX_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.S
	@$(ECHO) Info: Assembling $< to $@
	@$(MKDIR) $(@D)
	$(AS) -MP -MMD -c $(LIB_CPPFLAGS) $(LIB_CFLAGS) $(LIB_ASFLAGS) -o $@ $<
	$(AS_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.s
	@$(ECHO) Info: Assembling $< to $@
	@$(MKDIR) $(@D)
	$(AS) -MP -MMD -c $(LIB_CFLAGS) $(LIB_ASFLAGS) -o $@ $<
	$(AS_POST_PROCESS)

#------------------------------------------------------------------------------
#                     PATTERN RULES TO INTERMEDIATE FILES
#------------------------------------------------------------------------------

$(OBJ_ROOT_DIR)/%.s: %.c
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CC) -S $(LIB_CPPFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.s: %.cpp
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -S $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.s: %.cc
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -S $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.s: %.cxx
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -S $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.c
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CC) -E $(LIB_CPPFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.cpp
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -E $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.cc
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -E $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.cxx
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -E $(LIB_CPPFLAGS) $(LIB_CXXFLAGS) $(LIB_CFLAGS) -o $@ $<

#------------------------------------------------------------------------------
#                        TARGET RULES
#------------------------------------------------------------------------------

.PHONY : help
help :
	@$(ECHO) "Summary of Makefile targets"
	@$(ECHO) "  Build targets:"
	@$(ECHO) "    all (default) - Library, BSP and all libraries used by this library"
	@$(ECHO) "    lib           - Just the library"
ifneq ($(BSP_ROOT_DIR),)
	@$(ECHO) "    bsp           - Just the BSP"
endif
	@$(ECHO) "    libs          - BSP and all libraries used by this library" 
	@$(ECHO) "  Clean targets:"
	@$(ECHO) "    clean_all     - Library, BSP and all other makeable libraries"
	@$(ECHO) "    clean         - Just the library"
ifneq ($(BSP_ROOT_DIR),)
	@$(ECHO) "    clean_bsp     - Just the BSP"
endif
	@$(ECHO) "    clean_libs    - BSP and all libraries used by this library" 

# Handy rule to skip making libraries and just make main library.
.PHONY : lib
lib : $(LIB)

ifneq ($(BSP_ROOT_DIR),)
# Handy rule for making just the BSP.
.PHONY : bsp
bsp : 
	@$(ECHO) Info: Building $(BSP_ROOT_DIR)
	@$(MAKE) --no-print-directory -C $(BSP_ROOT_DIR)
endif

# This target is just provided for backwards compatibility with the 7.1 release.
.PHONY : makeable_libs
makeable_libs : libs

# Make sure all makeable libraries (including the BSP) are up-to-date.
LIB_TARGETS := $(patsubst %,%-recurs-make-lib,$(MAKEABLE_LIBRARY_ROOT_DIRS))

.PHONY : libs
libs : $(LIB_TARGETS)

ifneq ($(strip $(LIB_TARGETS)),)
$(LIB_TARGETS): %-recurs-make-lib:
	@$(ECHO) Info: Building $*
	$(MAKE) --no-print-directory -C $*
endif

# Rules to force your project to rebuild or relink
# .force_rearchive file will force this library to archive (ar) 
# .force_relink file will cause any application that depends on this project to relink 
# .force_rebuild file will cause this project to rebuild object files
# .force_rebuild_all file will cause this project and any project that depends on this project to rebuild object files

FORCE_REARCHIVE := .force_rearchive
FORCE_RELINK_DEP  := .force_relink
FORCE_REBUILD_DEP := .force_rebuild
FORCE_REBUILD_ALL_DEP := .force_rebuild_all
FORCE_REBUILD_DEP_LIST := $(FORCE_REARCHIVE) $(FORCE_RELINK_DEP) $(FORCE_REBUILD_DEP) $(FORCE_REBUILD_ALL_DEP)

$(FORCE_REBUILD_DEP_LIST):

$(LIB_OBJS): $(wildcard $(FORCE_REBUILD_DEP)) $(wildcard $(addsuffix /$(FORCE_REBUILD_ALL_DEP), . $(ALT_LIBRARY_DIRS)))

$(LIB) : $(wildcard $(FORCE_REARCHIVE))

# Clean just the library.
.PHONY : clean
clean :
	@$(RM) -r $(LIB) $(OBJ_ROOT_DIR) $(FORCE_REBUILD_DEP_LIST)
	@$(ECHO) [$(LIB_NAME) clean complete]	

ifneq ($(BSP_ROOT_DIR),)
# Clean just the BSP.
.PHONY : clean_bsp
clean_bsp :
	@$(ECHO) Info: Cleaning $(BSP_ROOT_DIR)
	@$(MAKE) --no-print-directory -C $(BSP_ROOT_DIR) clean
endif

# This target is just provided for backwards compatibility with the 7.1 release.
.PHONY : clean_makeable_libs
clean_makeable_libs : clean_libs

# Clean all makeable libraries including the BSP.
LIB_CLEAN_TARGETS := $(patsubst %,%-recurs-make-clean-lib,$(MAKEABLE_LIBRARY_ROOT_DIRS))

.PHONY : clean_libs
clean_libs : $(LIB_CLEAN_TARGETS)

ifneq ($(strip $(LIB_CLEAN_TARGETS)),)
$(LIB_CLEAN_TARGETS): %-recurs-make-clean-lib:
	@$(ECHO) Info: Cleaning $*
	$(MAKE) --no-print-directory -C $* clean
endif


# Clean library and all makeable libraries including the BSP.
.PHONY : clean_all
clean_all : clean clean_libs


# Include the dependency files unless the make goal is performing a clean
# of the library.
ifneq ($(firstword $(MAKECMDGOALS)),clean)
ifneq ($(firstword $(MAKECMDGOALS)),clean_all)
-include $(LIB_DEPS)
endif
endif

# Delete the target of a rule if it has changed and its commands exit
# with a nonzero exit status.
.DELETE_ON_ERROR:

#------------------------------------------------------------------------------
#                         AR TARGET RULE
#------------------------------------------------------------------------------
# Rule for constructing the library file.
$(LIB) : $(LIB_OBJS)
	@$(ECHO) Info: Archiving $@
	$(RM) -f $@
	$(AR) $(LIB_ARFLAGS) $@ $^


