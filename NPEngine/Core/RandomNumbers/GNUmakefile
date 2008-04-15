include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=RandomNumberGeneration
LIBRARY_NAME=libRandomNumberGeneration

libRandomNumberGeneration_HEADER_FILES = \
NPRandomNumberGenerator.h \
NPGaussianRandomNumberGenerator.h \
NPRandomNumberGeneratorManager.h

libRandomNumberGeneration_OBJC_FILES = \
NPRandomNumberGenerator.m \
NPGaussianRandomNumberGenerator.m \
NPRandomNumberGeneratorManager.m

libRandomNumberGeneration_LDFLAGS += -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/library.make
include $(TGDA_DIR)/GNUmakefile.library.install
