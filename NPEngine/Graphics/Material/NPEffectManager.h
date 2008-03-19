#import "Core/NPObject/NPObject.h"
#import "Cg/cg.h"

#define NP_CG_IMMEDIATE_SHADER_PARAMETER_UPDATE  0
#define NP_CG_DEFERRED_SHADER_PARAMETER_UPDATE   1

#define NP_CG_DEBUG_MODE_INACTIVE                0
#define NP_CG_DEBUG_MODE_ACTIVE                  1

@class NPEffect;

@interface NPEffectManager : NPObject
{
    CGcontext cgContext;

    NPState cgDebugMode;
    NPState shaderParameterUpdatePolicy;

    NSMutableDictionary * effects;
    NPEffect * currentActiveEffect;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (CGcontext)cgContext;

- (NPState) cgDebugMode;
- (void) setCgDebugMode:(NPState)newMode;

- (NPState)shaderParameterUpdatePolicy;
- (void) setShaderParameterPolicy:(NPState)newShaderParameterUpdatePolicy;

- (NPEffect *) currentActiveEffect;
- (void) setCurrentActiveEffect:(NPEffect *)newCurrentActiveEffect;

- (id) loadEffectFromPath:(NSString *)path;
- (id) loadEffectFromAbsolutePath:(NSString *)path;
- (id) loadEffectUsingFileHandle:(NPFile *)file;

@end
