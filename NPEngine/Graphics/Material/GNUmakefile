include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=NPEngineGraphicsMaterial
LIBRARY_NAME=libNPEngineGraphicsMaterial

libNPEngineGraphicsMaterial_OBJC_FILES = \
NPEffect.m \
NPEffectManager.m \
NPSUXMaterialInstance.m \
NPTexture.m \
NPTextureManager.m \
NPTextureBindingState.m \
NPTextureBindingStateManager.m

libNPEngineGraphicsMaterial_HEADER_FILES = \
NPEffect.h \
NPEffectManager.h \
NPSUXMaterialInstance.h \
NPTexture.h \
NPTextureManager.h \
NPTextureBindingState.h \
NPTextureBindingStateManager.h

libNPEngineGraphicsMaterial_LIBRARIES_DEPEND_UPON += -lNPEngineCoreUtilities

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/library.make
include $(TGDA_DIR)/GNUmakefile.library.install
