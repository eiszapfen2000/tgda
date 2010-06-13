#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class FAttractor;
@class FTerrain;
@class FCamera;
@class FPreethamSkylight;
@class FMenu;

@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;
@class NPFullscreenQuad;
@class NPSUXModel;

#define FSCENE_DRAW_TERRAIN     0
#define FSCENE_DRAW_ATTRACTOR   1

@interface FScene : NPObject
{
    FMenu * attractorMenu;
    FMenu * terrainMenu;

    FAttractor * attractor;
    FTerrain * terrain;
    FPreethamSkylight * skylight;
    FCamera * camera;

    // Bloom stuff for attractor scene
    float bloomThreshold;
    float bloomIntensity;
    float bloomSaturation;
    float sceneIntensity;
    float sceneSaturation;

    // Tonemapping stuff for terrain scene
    Float referenceWhite;
    Float key;
    Float adaptationTimeScale;
    Int32 luminanceMaxMipMapLevel;
    Float lastFrameLuminance;
    Float currentFrameLuminance;

    NpState activeScene;

    NPEffect * fullscreenEffect;
    CGparameter bloomThresholdParameter;
    CGparameter bloomIntensityParameter;
    CGparameter bloomSaturationParameter;
    CGparameter sceneIntensityParameter;
    CGparameter sceneSaturationParameter;
    CGparameter toneMappingParameters;

    NPRenderTargetConfiguration * attractorRTC;
    NPRenderTargetConfiguration * terrainRTC;
    NPRenderTexture * attractorScene;
    NPRenderTexture * terrainScene;
    NPRenderTexture * bloomTargetOne;
    NPRenderTexture * bloomTargetTwo;
    NPRenderTexture * luminanceTarget;
    NPRenderBuffer * depthBuffer;

    NPFullscreenQuad * fullscreenQuad;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (FCamera *) camera;
- (FAttractor *) attractor;
- (FTerrain *) terrain;
- (FPreethamSkylight *) skylight;

- (NpState) activeScene;
- (void) setActiveScene:(NpState)neewActiveScene;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
