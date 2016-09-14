include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=OceanSpectra

OceanSpectra_OBJC_FILES = \
    main.m \
    ODFrequencySpectrumFloat.m \
    ODPFrequencySpectrumGeneration.m

OceanSpectra_C_FILES = \
    ODAmplitude.c \
    ODEnergy.c \
    ODGaussianRNG.c

ADDITIONAL_TOOL_LIBS += -lNPEngine2 -lglfw -lprng -lfftw3 -lfftw3f

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/tool.make

