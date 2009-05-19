#import "Core/NPObject/NPObject.h"
#import "Core/File/NpFile.h"
#import "Graphics/npgl.h"

@class NPEffect;
@class NPEffectTechnique;

@interface NPEffectManager : NPObject
{
    CGcontext cgContext;

    NpState cgDebugMode;
    NpState shaderParameterUpdatePolicy;

    NSMutableDictionary * effects;
    NPEffect * currentEffect;
    NPEffectTechnique * currentTechnique;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (CGcontext)cgContext;
- (NpState) cgDebugMode;
- (NpState) shaderParameterUpdatePolicy;
- (NPEffect *) currentEffect;
- (NPEffectTechnique *) currentTechnique;

- (void) setCgDebugMode:(NpState)newMode;
- (void) setShaderParameterPolicy:(NpState)newShaderParameterUpdatePolicy;
- (void) setCurrentEffect:(NPEffect *)newCurrentEffect;
- (void) setCurrentTechnique:(NPEffectTechnique *)newCurrentEffectTechnique;

- (id) loadEffectFromPath:(NSString *)path;
- (id) loadEffectFromAbsolutePath:(NSString *)path;
- (id) loadEffectUsingFileHandle:(NPFile *)file;

@end
