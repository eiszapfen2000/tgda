#import "Core/Basics/NpBasics.h"
#import "Core/Protocols/NPPObject.h"

@class NPAssetArray;
@class NPEngineGraphicsStringEnumConversion;
@class NPStateConfiguration;

@interface NPEngineGraphics : NSObject < NPPObject >
{
    uint32_t objectID;

    NPEngineGraphicsStringEnumConversion * stringEnumConversion;

    NPAssetArray * images;
    NPAssetArray * textures2D;
    NPAssetArray * effects;

    NPStateConfiguration * stateConfiguration;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (void) dealloc;

- (NPEngineGraphicsStringEnumConversion *) stringEnumConversion;

- (NPAssetArray *) images;
- (NPAssetArray *) textures2D;
- (NPAssetArray *) effects;

- (NPStateConfiguration *) stateConfiguration;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) update;
- (void) render;

@end

