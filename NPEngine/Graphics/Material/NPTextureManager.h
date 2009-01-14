#import "Core/NPObject/NPObject.h"

@class NPFile;

@interface NPTextureManager : NPObject
{
    NSMutableDictionary * textures;
    Int maxAnisotropy;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (Int) maxAnisotropy;

- (GLenum) computeGLDataFormat:(NpState)dataFormat;
- (GLenum) computeGLPixelFormat:(NpState)pixelFormat;
- (GLint)  computeGLInternalTextureFormatUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat;

- (id) loadTextureFromPath:(NSString *)path;
- (id) loadTextureFromAbsolutePath:(NSString *)path;
- (id) loadTextureUsingFileHandle:(NPFile *)file;

@end
