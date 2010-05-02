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
RTVArbitraryBoundaries.m \
RTVFluid.m \
RTVMenu.m \
RTVCheckBoxItem.m \
RTVSelectionGroup.m \
RTVSliderItem.m

RTV_RESOURCE_FILES = \
RTV.gorm \
Content

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU -lprng -lopenal -lvorbis -lvorbisfile

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

