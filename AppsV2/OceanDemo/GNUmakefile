include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=OceanDemo

OceanDemo_SUBPROJECTS = \
    Entities

OceanDemo_HEADER_FILES = \
    ODScene.h

OceanDemo_OBJC_FILES = \
    ODScene.m \
    main.m

ADDITIONAL_TOOL_LIBS += -lGL -lGLU -lNPEngine2 -lGLEW -lIL -lILU -lopenal -lvorbisfile -lglfw

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make

