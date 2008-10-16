include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=NPEngineGraphics
LIBRARY_NAME=libNPEngineGraphics

SUBPROJECTS = \
    Camera \
    Image \
	Material \
	Model \
	RenderContext \
    RenderTarget \
    State

libNPEngineGraphics_OBJC_FILES = \
NPEngineGraphics.m

libNPEngineGraphics_HEADER_FILES = \
NPEngineGraphics.h

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/library.make
include $(TGDA_DIR)/GNUmakefile.library.install

