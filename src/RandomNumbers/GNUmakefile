include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=RandomNumberGeneration
LIBRARY_NAME=libRandomNumberGeneration

libRandomNumberGeneration_HEADER_FILES = \
NPRandomNumberGeneration.h

libRandomNumberGeneration_OBJC_FILES = \
NPRandomNumberGeneration.m

libRandomNumberGeneration_LDFLAGS += -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/library.make
include $(TGDA_DIR)/GNUmakefile.library.install
