include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = OceanDemo

OceanDemo_OBJC_FILES = \
main.m \
ODApplicationController.m  \
ODCamera.m \
ODProjector.m \
ODFrustum.m \
ODScene.m \
ODSceneManager.m \
ODEntity.m \
ODOceanEntity.m \
ODEntityManager.m \
ODSurface.m \
ODPerlinNoise.m

OceanDemo_RESOURCE_FILES = \
Info-gnustep.plist \
OceanDemo.gorm \
Content

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

