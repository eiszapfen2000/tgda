include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME=libNPEngineGraphicsMaterial

libNPEngineGraphicsMaterial_OBJC_FILES = \
NPEffect.m \
NPEffectTechnique.m \
NPEffectManager.m \
NPSUXMaterialInstance.m \
NPTexture.m \
NPTexture3D.m \
NPTextureManager.m \
NPTextureBindingState.m

libNPEngineGraphicsMaterial_C_FILES = \
NpTexture.c

libNPEngineGraphicsMaterial_HEADER_FILES = \
NPEffect.h \
NPEffectTechnique.h \
NPEffectManager.h \
NPSUXMaterialInstance.h \
NPTexture.h \
NPTexture3D.h \
NPTextureManager.h \
NPTextureBindingState.h

libNPEngineGraphicsMaterial_LIBRARIES_DEPEND_UPON += -lCg -lCgGL

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/subproject.make

