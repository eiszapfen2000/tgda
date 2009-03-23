include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Fraktale

Fraktale_OBJC_FILES = \
main.m \
FCore.m \
FApplicationController.m \
FWindowController.m \
FSceneManager.m \
FScene.m \
FTerrain.m \
FPGMImage.m \
FCamera.m

Fraktale_RESOURCE_FILES = \
Info-gnustep.plist \
Fraktale.gorm \
FAttributesWindow.gorm \
Content

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

