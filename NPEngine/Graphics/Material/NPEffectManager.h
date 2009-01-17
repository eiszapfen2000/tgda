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
    NPEffect * currentEffect;
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

- (void) setCgDebugMode:(NpState)newMode;
- (void) setShaderParameterPolicy:(NpState)newShaderParameterUpdatePolicy;
- (void) setCurrentEffect:(NPEffect *)newCurrentEffect;

- (id) loadEffectFromPath:(NSString *)path;
- (id) loadEffectFromAbsolutePath:(NSString *)path;
- (id) loadEffectUsingFileHandle:(NPFile *)file;

@end
