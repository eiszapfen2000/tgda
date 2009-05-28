include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = RTV

RTV_OBJC_FILES = \
main.m \
RTVCore.m \
RTVApplicationController.m \
RTVSceneManager.m \
RTVScene.m \
RTVAdvection.m \
RTVDiffusion.m \
RTVInputForce.m \
RTVDivergence.m \
RTVPressure.m \
RTVFluid.m

RTV_RESOURCE_FILES = \
Info-gnustep.plist \
RTV.gorm \
Content

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU -lprng

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

