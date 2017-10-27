include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME=ODOcean

ODOcean_HEADER_FILES = \
ODGaussianRNG.h \
ODPFrequencySpectrumGeneration.h \
ODFrequencySpectrum.h \
ODFrequencySpectrumFloat.h \
ODEnergy.h

ODOcean_C_FILES = \
ODGaussianRNG.c \
ODEnergy.c

ODOcean_OBJC_FILES = \
ODPFrequencySpectrumGeneration.m \
ODFrequencySpectrum.m \
ODFrequencySpectrumFloat.m

TOOL_NAME=benchmark

benchmark_C_FILES = \
ODGaussianRNG.c \
ODEnergy.c

benchmark_OBJC_FILES = \
benchmark.m

ADDITIONAL_TOOL_LIBS += -lNPEngine2 -lGLEW -lGL -lprng -lfftw3f -lfftw3

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make
include $(GNUSTEP_MAKEFILES)/subproject.make

