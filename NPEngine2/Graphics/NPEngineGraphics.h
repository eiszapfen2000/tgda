#import "Core/Basics/NpBasics.h"
#import "Core/Protocols/NPPObject.h"

@class NPAssetArray;

@interface NPEngineGraphics : NSObject < NPPObject >
{
    uint32_t objectID;

    NPAssetArray * images;
    NPAssetArray * textures2D;
    NPAssetArray * shader;
    //NPAssetArray * effects;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (void) dealloc;

- (NPAssetArray *) images;
- (NPAssetArray *) textures2D;
- (NPAssetArray *) shader;
//- (NPAssetArray *) effects;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) update;
- (void) render;

@end

