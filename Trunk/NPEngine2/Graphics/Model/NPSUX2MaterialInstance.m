#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSPointerArray.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/String/NPStringList.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableSampler.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPSUX2MaterialInstanceCompiler.h"
#import "NPSUX2MaterialInstance.h"

@implementation NPSUX2MaterialInstance

- (id) init
{
    return [ self initWithName:@"SUX2 Material Instance" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    NSPointerFunctionsOptions options
        = NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsStrongMemory;

    textures = [[ NSPointerArray alloc ] initWithOptions:options ];
    [ textures setCount:SUX2_SAMPLER_COUNT ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(effect);
    [ textures setCount:0 ];
    DESTROY(textures);
    SAFE_DESTROY(file);

    [ super dealloc ];
}

- (NPEffect *) effect
{
    return effect;
}

- (NSString *) techniqueName
{
    return techniqueName;
}

- (void) addEffectFromFile:(NSString *)fileName
{
    SAFE_DESTROY(effect);

    effect
        = TEST_RETAIN(
            [[[ NPEngineGraphics
                    instance ] effects ] getAssetWithFileName:fileName ]);
}

- (void) setTechniqueName:(NSString *)newTechniqueName
{
    ASSIGNCOPY(techniqueName, newTechniqueName);
}

- (void) addTexture2DWithName:(NSString *)samplerName
                     fromFile:(NSString *)fileName
                         sRGB:(BOOL)sRGB
{
    NSDictionary * arguments = nil;
    if ( sRGB == YES )
    {
        arguments = [ NSDictionary dictionaryWithObject:@"YES" forKey:@"sRGB" ];
    }

    NPTexture2D * texture
        = (NPTexture2D *)[[[ NPEngineGraphics
                               instance ] textures2D ]
                                 getAssetWithFileName:fileName
                                            arguments:arguments ];

    if ( texture != nil )
    {
        NSAssert(effect != nil, @"Material instance misses effect");

        NPEffectVariableSampler * evSampler
            = [ effect variableWithName:samplerName ];

        const uint32_t texelUnit = [ evSampler texelUnit ];

        NSAssert(texelUnit < SUX2_SAMPLER_COUNT,
            @"Texelunit exceeds index");

        [ textures replacePointerAtIndex:texelUnit
                             withPointer:texture ];
    }
}

- (void) activate
{
    NPTextureBindingState * textureBindingState
        = [[ NPEngineGraphics instance ] textureBindingState ];

    for (uint32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        [ textureBindingState setTexture:[ textures pointerAtIndex:i ] texelUnit:i ];
    }    

    [ textureBindingState activate ];

    if ( effect != nil && techniqueName != nil )
    {
        [[ effect techniqueWithName:techniqueName ] activate ];
    }
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    NSString * materialInstanceName;
    NSString * materialScriptFileName;

    [ stream readSUXString:&materialInstanceName ];
    [ stream readSUXString:&materialScriptFileName ];

    NPStringList * materialInstanceScript
        = [[ NPStringList alloc ] initWithName:@""
                               allowDuplicates:YES
                             allowEmptyStrings:NO ];

    BOOL read
        = [ materialInstanceScript
              loadFromStream:stream
                       error:NULL ];

    if ( read == NO )
    {
        NPLOG(@"Failed to read material instance script");
    }

    NPLOG(materialInstanceName);
    NPLOG(materialScriptFileName);
    NPLOG([ materialInstanceScript description ]);

    NPSUX2MaterialInstanceCompiler * compiler
        = [[ NPSUX2MaterialInstanceCompiler alloc ] init ];

    [ compiler compileScript:materialInstanceScript
        intoMaterialInstance:self ];

    DESTROY(compiler);
    DESTROY(materialInstanceScript);

    return read;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

@end
