include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = OceanDemo

APP_NAME = OceanDemo

OceanDemo_OBJC_FILES = \
ODApplication.m \
ODApplicationController.m \
ODWindowController.m \
ODOpenGLView.m \
ODDemo.m \
ODCamera.m \
ODProjector.m \
ODFrustum.m \
ODScene.m \
ODSurface.m \
main.m

OceanDemo_RESOURCE_FILES = \
Info-gnustep.plist \
settings.plist \
Resources/OceanDemo.gorm

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngineCoreLog -lNPEngineCoreResource -lNPEngineCoreNPObject -lNPEngineCoreBasics -lNPEngineCoreTimer -lNPEngineCoreFile -lNPEngineCoreMath -lNPEngineCoreUtilities -lNPEngineCoreWorld -lNPEnginCoreRandomNumberGeneration -lNPEngineCore -lNPEngineGraphicsRenderContext -lNPEngineGraphicsModel -lNPEngineGraphicsMaterial -lNPEngineGraphicsImage -lNPEngineGraphicsCamera -lNPEngineGraphicsRenderTarget -lNPEngineGraphicsState -lNPEngineGraphics -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble

