#import "NPSUXMaterialInstanceCompiler.h"
#import "NPSUXMaterialInstance.h"
#import "NP.h"

@implementation NPSUXMaterialInstance

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPSUXMaterialInstance" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    materialFileName = @"";
    materialInstanceScript = [[ NPStringList alloc ] init ];
    [ materialInstanceScript setAllowDuplicates:YES ];
    [ materialInstanceScript setAllowEmptyStrings:YES ];

    textures2D = [[ NSMutableArray alloc ] initWithCapacity:NP_GRAPHICS_SAMPLER_COUNT ];
    for (Int32 i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ textures2D addObject:[ NSNull null ]];
    }

    return self;
}

- (void) dealloc
{
	DESTROY(effect);
    [ textures2D removeAllObjects ];
    DESTROY(textures2D);
    DESTROY(materialInstanceScript);
	DESTROY(materialFileName);

	[ super dealloc ];
}

- (NSString *) materialFileName
{
    return materialFileName;
}

- (void) setMaterialFileName:(NSString *)newMaterialFileName
{
    ASSIGN(materialFileName, newMaterialFileName);
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ]];

    NSString * materialInstanceName = [ file readSUXString ];
    [ self setName:materialInstanceName ];
    //NSLog(@"Material Instance Name: %@", name);

    NSString * materialScriptFileName = [ file readSUXString ];
    [ self setMaterialFileName:materialScriptFileName ];
    //NSLog(@"Material Script File: %@", materialFileName);

    if ( [ materialInstanceScript loadFromFile:file ] == NO )
    {
        return NO;
    }

    NPSUXMaterialInstanceCompiler * compiler = [[ NPSUXMaterialInstanceCompiler alloc ] init ];
    [ compiler compileInformationFromScript:materialInstanceScript
                    intoSUXMaterialInstance:self ];

    DESTROY(compiler);

    ready = YES;

    return YES;
}

- (BOOL) saveToFile:(NPFile *)file
{
    if ( ready == NO )
    {
        return NO;
    }

    [ file writeSUXString:name ];
    [ file writeSUXString:materialFileName ];
    [ file writeSUXScript:materialInstanceScript ];

    return YES;
}

- (void) reset
{
    DESTROY(materialFileName);
    materialFileName = @"";

    [ materialInstanceScript clear ];

    [ super reset ];
}

- (NPEffect *) effect
{
    return effect;
}

- (void) addEffectFromPath:(NSString *)path
{
    TEST_RELEASE(effect);

    effect = [[[[ NP Graphics ] effectManager ] loadEffectFromPath:path ] retain ];
}

- (void) setEffectTechniqueByName:(NSString *)techniqueName
{
    if ( effect == nil )
    {
        NPLOG_ERROR(@"Effect missing");
        return;
    }

    [ effect setDefaultTechniqueByName:techniqueName ];
}

- (void) addTexture2DWithName:(NSString *)samplerName
                     fromPath:(NSString *)path
                         sRGB:(BOOL)sRGB
{
    Int colormapIndex = [ effect colormapIndexForSamplerWithName:samplerName ];
    if ( colormapIndex < 0 )
    {
        NPLOG_ERROR(@"No match for %@ found in %@", samplerName, [ effect name ]);
        return;
    }

    NPTexture * texture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:path sRGB:sRGB ];
    if ( texture != nil )
    {
        [ textures2D insertObject:texture atIndex:colormapIndex ];
    }
}

- (void) activate
{
    for (Int32 i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        id t = [ textures2D objectAtIndex:i ];

        if ( t != [ NSNull null ] )
        {
            [ t activateAtColorMapIndex:i ];
        }
    }    

    [ effect activate ];
}

@end
