#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class FAttractor;
@class FTerrain;
@class FCamera;

@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;
@class NPFullscreenQuad;

@interface FScene : NPObject
{
    FAttractor * attractor;
    FTerrain * terrain;
    FCamera * camera;

    NPEffect * fullscreenEffect;
    CGparameter bloomThresholdParameter;
    CGparameter bloomIntensityParameter;
    CGparameter bloomSaturationParameter;
    CGparameter sceneIntensityParameter;
    CGparameter sceneSaturationParameter;

    NPRenderTargetConfiguration * attractorRTC;
    NPRenderTexture * originalScene;
    NPRenderTexture * colorTargetOne;
    NPRenderTexture * colorTargetTwo;
    NPRenderBuffer * depthBuffer;

    NPFullscreenQuad * fullscreenQuad;
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
