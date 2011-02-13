#import "Core/Basics/NpBasics.h"
#import "Core/Protocols/NPPObject.h"

@class NPAssetArray;
@class NPEngineGraphicsStringEnumConversion;

@interface NPEngineGraphics : NSObject < NPPObject >
{
    uint32_t objectID;

    NPEngineGraphicsStringEnumConversion * stringEnumConversion;

    NPAssetArray * images;
    NPAssetArray * textures2D;
    NPAssetArray * shader;
    NPAssetArray * effects;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (void) dealloc;

- (NPEngineGraphicsStringEnumConversion *) stringEnumConversion;

- (NPAssetArray *) images;
- (NPAssetArray *) textures2D;
- (NPAssetArray *) shader;
- (NPAssetArray *) effects;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) update;
- (void) render;

@end

