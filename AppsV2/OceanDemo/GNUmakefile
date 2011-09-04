include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=OceanDemo

OceanDemo_SUBPROJECTS = \
    Entities \
    Menu

OceanDemo_HEADER_FILES = \
    ODScene.h \
    ODSemaphore.h

OceanDemo_OBJC_FILES = \
    ODScene.m \
    ODSemaphore.m \
    main.m

OceanDemo_RESOURCE_FILES = \
Content

ADDITIONAL_TOOL_LIBS += -lGL -lGLU -lNPEngine2 -lGLEW -lIL -lILU -lopenal -lvorbisfile -lglfw

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make

