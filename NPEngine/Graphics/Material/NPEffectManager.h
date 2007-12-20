#import "Core/NPObject/NPObject.h"
#import "NPEffect.h"

#import "Cg/cg.h"
#import "Cg/cgGL.h"

typedef enum
{
    NP_NONE = -1,
    NP_CG_IMMEDIATE_SHADER_PARAMETER_UPDATE = 0,
    NP_CG_DEFERRED_SHADER_PARAMETER_UPDATE = 1
}
NpCgShaderParameterUpdatePolicy;

@interface NPEffectManager : NPObject
{
    CGcontext cgContext;
    BOOL cgDebugMode;
    NpCgShaderParameterUpdatePolicy shaderParameterUpdatePolicy;

    NSMutableDictionary * effects;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (CGcontext)cgContext;

- (BOOL) cgDebugMode;
- (void) setCgDebugMode:(BOOL)newMode;

- (NpCgShaderParameterUpdatePolicy)shaderParameterUpdatePolicy;
- (void) setShaderParamterPolicy:(NpCgShaderParameterUpdatePolicy)newShaderParameterUpdatePolicy;



@end
