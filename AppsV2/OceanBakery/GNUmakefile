include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=OceanBakery

OceanBakery_HEADER_FILES = \
OBRNG.h \
OBGaussianRNG.h \
OBPhillipsSpectrum.h \
OBOceanSurfaceSlice.h \
OBOceanSurface.h \
OBOceanSurfaceManager.h \
OBOceanSurfaceGenerationConfiguration.h

OceanBakery_OBJC_FILES = \
OBRNG.m \
OBGaussianRNG.m \
OBPhillipsSpectrum.m \
OBOceanSurfaceSlice.m \
OBOceanSurface.m \
OBOceanSurfaceManager.m \
OBOceanSurfaceGenerationConfiguration.m \
main.m

ADDITIONAL_TOOL_LIBS += -lfftw3f -lfftw3f_threads -lGL -lGLU -lNPEngine2 -lGLEW -lIL -lILU -lprng -lopenal -lvorbisfile

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make

