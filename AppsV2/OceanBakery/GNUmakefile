include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=OceanBakery

OceanBakery_HEADER_FILES = \
OBOceanSurfaceGenerationConfiguration.h \
OBOceanSurfaceManager.h \
OBOceanSurface.h \
OBOceanSurfaceSlice.h \
OBPhillipsSpectrum.h

OceanBakery_OBJC_FILES = \
OBOceanSurfaceGenerationConfiguration.m \
OBOceanSurfaceManager.m \
OBOceanSurface.m \
OBOceanSurfaceSlice.m \
OBPhillipsSpectrum.m \
main.m

ADDITIONAL_TOOL_LIBS += -lfftw3f -lfftw3f_threads -lGL -lGLU -lNPEngine -lCg -lCgGL -lGLEW -lIL -lILU -lprng $(GUI_LIBS)

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make

