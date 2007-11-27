include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = TiledOcean

APP_NAME = TiledOcean

TiledOcean_OBJC_FILES = \
TODocument.m \
TOOceanSurface.m \
TOOGLWindowController.m \
TOOpenGLView.m \
TORNGWindowController.m \
main.m


TiledOcean_RESOURCE_FILES = \
Info-gnustep.plist \
Resources/TiledOcean.gorm \
Resources/TODocument.gorm \
Resources/TORNGSettingsWindow.gorm

ADDITIONAL_GUI_LIBS += -lGL -lGLU -lfftw3_threads -lfftw3 -lRandomNumberGeneration -lMath -lBasics -lNPEngineCore -lNPEngineImage -lIL -lILU -lILUT -lprng


include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble 
