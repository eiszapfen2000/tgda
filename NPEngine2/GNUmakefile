include $(GNUSTEP_MAKEFILES)/common.make

NATIVE_LIBRARY_NAME=libNPEngine2

libNPEngine2_SUBPROJECTS = \
    Log \
    Core \
    Graphics \
    Input \
    Sound

libNPEngine2_OBJC_FILES = \
NP.m

libNPEngine2_HEADER_FILES = \
NP.h

libNPEngine2_LIBRARIES_DEPEND_UPON += -lGL -lGLU -lGLEW -lIL -lILU -lopenal -lvorbisfile

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/native-library.make
include $(TGDA_DIR)/GNUmakefile.library.install

