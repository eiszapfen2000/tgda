#import "Core/NPObject/NPObject.h"

@class FAttractor;
@class FTerrain;
@class FCamera;

@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;

@interface FScene : NPObject
{
    FAttractor * attractor;
    FTerrain * terrain;
    FCamera * camera;

    NPEffect * fullscreenEffect;
    NPRenderTargetConfiguration * attractorRTC;
    NPRenderTexture * colorTargetOne;
    NPRenderTexture * colorTargetTwo;
    NPRenderBuffer * depthBuffer;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (FAttractor *) attractor;
- (FTerrain *) terrain;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
