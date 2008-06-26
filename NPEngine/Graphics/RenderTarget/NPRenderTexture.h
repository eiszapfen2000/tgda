#import "Core/NPObject/NPObject.h"

@class NPTexture;

@interface NPRenderTexture : NPObject
{
	UInt renderTextureID;

    Int width;
    Int height;

    NPState type;
	NPState format;

    NPRenderTargetConfiguration * configuration;

    BOOL ready;
}

+ (id) renderTextureWithName:(NSString *)name type:(NPState)type format:(NPState)format width:(Int)width height:(Int)height;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) checkForReadiness;
- (BOOL) ready;
- (Int) width;
- (void) setWidth:(Int)newWidth;
- (Int) height;
- (void) setHeight:(Int)newHeight;
- (NPState) type;
- (void) setType:(NPState)newType;
- (NPState) format;
- (void) setFormat:(NPState)newFormat;

- (void) uploadToGL;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration;

@end
