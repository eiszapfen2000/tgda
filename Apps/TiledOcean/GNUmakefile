include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = TiledOcean

APP_NAME = TiledOcean

TiledOcean_OBJC_FILES = \
NPOpenGLView.m \
TOCamera.m \
TODocument.m \
TODocumentController.m \
TOOGLWindowController.m \
TOOpenGLView.m \
TOScene.m \
TOOceanSurfaceGeneratorSettingsWindowController.m \
TOOceanSurfaceGenerator.m \
TOFrequencySpectrumGenerator.m \
main.m


TiledOcean_RESOURCE_FILES = \
Info-gnustep.plist \
Resources/TiledOcean.gorm \
Resources/TODocument.gorm \
Resources/TOOceanSurfaceGeneratorSettingsWindow.gorm

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lNPEngineCoreLog -lNPEngineCoreResource -lNPEngineCoreNPObject -lNPEngineCoreBasics -lNPEngineCoreTimer -lNPEngineCoreFile -lNPEngineCoreMath -lNPEngineCoreUtilities -lNPEngineCoreWorld -lNPEnginCoreRandomNumberGeneration -lNPEngineCore -lNPEngineGraphicsRenderContext -lNPEngineGraphicsModel -lNPEngineGraphicsMaterial -lNPEngineGraphicsImage -lNPEngineGraphicsCamera -lCg -lCgGL -lGLEW -lIL -lILU -lfftw3 -lfftw3_threads


include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble

