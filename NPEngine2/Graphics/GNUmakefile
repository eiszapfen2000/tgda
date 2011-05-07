include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME=libNPEngineGraphics

libNPEngineGraphics_SUBPROJECTS = \
    Image \
    Texture \
    Effect \
    Buffer \
    Geometry \
    Model \
    RenderTarget \
    State

libNPEngineGraphics_C_FILES = \
NPEngineGraphicsEnums.c

libNPEngineGraphics_OBJC_FILES = \
NPEngineGraphics.m \
NPEngineGraphicsStringEnumConversion.m \
NPEngineGraphicsStringToClassConversion.m \
NSString+NPEngineGraphicsEnums.m \
NSString+NPEngineGraphicsClasses.m \
NPViewport.m

libNPEngineGraphics_HEADER_FILES = \
NPEngineGraphics.h \
NPEngineGraphicsEnums.h \
NPEngineGraphicsErrors.h \
NPEngineGraphicsStringEnumConversion.h \
NPEngineGraphicsStringToClassConversion.h \
NSString+NPEngineGraphicsEnums.h \
NSString+NPEngineGraphicsClasses.h \
NPViewport.h

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/subproject.make



