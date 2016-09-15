include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=OceanDemo

OceanDemo_SUBPROJECTS = \
    Entities \
    Menu

OceanDemo_HEADER_FILES = \
	ODVariance.h \
    ODScene.h

OceanDemo_OBJC_FILES = \
	ODVariance.m \
    ODScene.m \
    main.m

OceanDemo_RESOURCE_FILES = \
Content

ADDITIONAL_TOOL_LIBS += -lNPEngine2 -lglfw -lGLEW -lGL -lprng -lfftw3 -lfftw3f

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make

