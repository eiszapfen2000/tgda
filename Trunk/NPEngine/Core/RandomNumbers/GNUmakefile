include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME=libNPEnginCoreRandomNumberGeneration

libNPEnginCoreRandomNumberGeneration_HEADER_FILES = \
NPRandomNumberGenerator.h \
NPGaussianRandomNumberGenerator.h \
NPRandomNumberGeneratorManager.h

libNPEnginCoreRandomNumberGeneration_OBJC_FILES = \
NPRandomNumberGenerator.m \
NPGaussianRandomNumberGenerator.m \
NPRandomNumberGeneratorManager.m

libNPEnginCoreRandomNumberGeneration_LIBRARIES_DEPEND_UPON += -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/subproject.make

