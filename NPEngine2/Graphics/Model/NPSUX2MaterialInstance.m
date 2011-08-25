#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNull.h>
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

    textures = [[ NSMutableArray alloc ] initWithCapacity:SUX2_SAMPLER_COUNT ];
    for (uint32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        [ textures addObject:[ NSNull null ]];
    }

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(effect);
    [ textures removeAllObjects ];
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
        = [[[ NPEngineGraphics
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

        [ textures replaceObjectAtIndex:texelUnit
                             withObject:texture ];
    }
}

- (void) activate
{
    id null = [ NSNull null ];

    NPTextureBindingState * textureBindingState
        = [[ NPEngineGraphics instance ] textureBindingState ];

    for (uint32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        id texture = [ textures objectAtIndex:i ];
        if ( texture != null )
        {
            [ textureBindingState setTexture:texture texelUnit:i ];
        }
    }    

    [ textureBindingState activate ];
    [[ effect techniqueWithName:techniqueName ] activate ];
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
