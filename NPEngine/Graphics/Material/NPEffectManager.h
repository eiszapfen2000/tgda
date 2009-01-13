#import "Core/NPObject/NPObject.h"
#import "Core/File/NpFile.h"
#import "Graphics/npgl.h"

@class NPEffect;

@interface NPEffectManager : NPObject
{
    CGcontext cgContext;

    NpState cgDebugMode;
    NpState shaderParameterUpdatePolicy;

    NSMutableDictionary * effects;
    NPEffect * currentActiveEffect;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (CGcontext)cgContext;

- (NpState) cgDebugMode;
- (void) setCgDebugMode:(NpState)newMode;

- (NpState)shaderParameterUpdatePolicy;
- (void) setShaderParameterPolicy:(NpState)newShaderParameterUpdatePolicy;

- (NPEffect *) currentActiveEffect;
- (void) setCurrentActiveEffect:(NPEffect *)newCurrentActiveEffect;

- (id) loadEffectFromPath:(NSString *)path;
- (id) loadEffectFromAbsolutePath:(NSString *)path;
- (id) loadEffectUsingFileHandle:(NPFile *)file;

@end
