include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = OceanDemo

OceanDemo_SUBPROJECTS = \
    Entities \
    Menu \
    Ocean \
    Utilities

OceanDemo_OBJC_FILES = \
main.m \
ODApplicationController.m  \
ODScene.m \
ODSceneManager.m \
ODCore.m

OceanDemo_RESOURCE_FILES = \
Info-gnustep.plist \
OceanDemo.gorm \
Content

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make


