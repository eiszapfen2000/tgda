include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME=libNPEngineSound

libNPEngineSound_HEADER_FILES = \
NPEngineSound.h \
NPListener.h \
NPSoundSample.h \
NPSoundSource.h \
NPSoundSources.h \
NPSoundStream.h \
NPVorbisErrors.h

libNPEngineSound_OBJC_FILES = \
NPEngineSound.m \
NPListener.m \
NPSoundSample.m \
NPSoundSource.m \
NPSoundSources.m \
NPSoundStream.m \
NPVorbisErrors.m

libNPEngineSound_LIBRARIES_DEPEND_UPON += -lopenal -lvorbis -lvorbisfile

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/subproject.make



