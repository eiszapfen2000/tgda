include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=NPEngineGraphicsRenderContext
LIBRARY_NAME=libNPEngineGraphicsRenderContext

libNPEngineGraphicsRenderContext_OBJC_FILES = \
NPOpenGLPixelFormat.m \
NPOpenGLRenderContext.m \
NPOpenGLRenderContextManager.m

libNPEngineGraphicsRenderContext_HEADER_FILES = \
NPOpenGLPixelFormat.h \
NPOpenGLRenderContext.h \
NPOpenGLRenderContextManager.h

libNPEngineGraphicsRenderContext_LIBRARIES_DEPEND_UPON += -lGLEW

include $(TGDA_DIR)/GNUmakefile.flags
include $(GNUSTEP_MAKEFILES)/library.make
include $(TGDA_DIR)/GNUmakefile.library.install
