include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME=libNPEngineGraphicsImage

libNPEngineGraphicsImage_HEADER_FILES = \
NPImage.h \
NPImageManager.h \
NPPixelBuffer.h \
NPPixelBufferManager.h

libNPEngineGraphicsImage_OBJC_FILES = \
NPImage.m \
NPImageManager.m \
NPPixelBuffer.m \
NPPixelBufferManager.m 

libNPEngineGraphicsImage_LIBRARIES_DEPEND_UPON += -lIL -lILU

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/subproject.make

