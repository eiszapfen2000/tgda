#import "Core/NPObject/NPObject.h"

@class NPRenderTargetConfiguration;

@interface NPRenderBuffer : NPObject
{
	UInt renderBufferID;
    NpState type;
	NpState format;
    Int width;
    Int height;

    NPRenderTargetConfiguration * configuration;
}

+ (id) renderBufferWithName:(NSString *)name 
                       type:(NpState)type 
                     format:(NpState)format
                      width:(Int)width 
                     height:(Int)height
                           ;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) generateGLRenderBufferID;

- (Int) width;
- (Int) height;
- (NpState) type;
- (NpState) format;

- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setType:(NpState)newType;
- (void) setFormat:(NpState)newFormat;

- (void) uploadToGL;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration;
- (void) unbindFromRenderTargetConfiguration;

@end
