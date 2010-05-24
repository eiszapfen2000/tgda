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
@class NPSUXModel;

typedef struct FBloomSettings
{
    float bloomThreshold;
    float bloomIntensity;
    float bloomSaturation;
    float sceneIntensity;
    float sceneSaturation;
}
FBloomSettings;

void fbloomsettings_init(FBloomSettings * bloomSettings);

#define FSCENE_DRAW_TERRAIN     0
#define FSCENE_DRAW_ATTRACTOR   1

@interface FScene : NPObject
{
    FAttractor * attractor;
    FTerrain * terrain;
    FCamera * camera;

    FBloomSettings bloomSettings;

    NpState activeScene;

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

    NPSUXModel * model;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (FAttractor *) attractor;
- (FTerrain *) terrain;

- (NpState) activeScene;
- (void) setActiveScene:(NpState)neewActiveScene;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
