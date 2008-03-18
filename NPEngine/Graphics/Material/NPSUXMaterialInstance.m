#import "NPSUXMaterialInstance.h"
#import "Core/Utilities/NPStringUtilities.h"
#import "NPTexture.h"
#import "NPTextureManager.h"
#import "NPEffect.h"
#import "NPEffectManager.h"
#import "Core/NPEngineCore.h"

@implementation NPSUXMaterialInstance

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPSUXMaterialInstance" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    materialFileName = @"";
    materialInstanceScript = nil;
    textureNameToSemantic = [ [ NSMutableDictionary alloc ] init ];
    textureNameToTextureFileName = [ [ NSMutableDictionary alloc ] init ];
    textureFileNameToTexture = [ [ NSMutableDictionary alloc ] init ];
    textureToSemantic = [ [ NSMutableDictionary alloc ] init ];

    effect = nil;

    return self;
}

- (NSString *)materialFileName
{
    return materialFileName;
}

- (void) setMaterialFileName:(NSString *)newMaterialFileName
{
    if ( materialFileName != newMaterialFileName )
    {
        [ materialFileName release ];
        materialFileName = [ newMaterialFileName retain ];
    }
}

- (void) removeInvalidLinesFromMaterialInstanceScript
{
    NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    NSMutableArray * validLines = [ [ NSMutableArray alloc ] init ];

    NSEnumerator * enumerator = [ materialInstanceScript objectEnumerator ];
    NSString * materialInstanceScriptLine;

    while ( (materialInstanceScriptLine = [ enumerator nextObject ]) )
    {
        NSMutableArray * elements = [ splitStringUsingCharacterSet(materialInstanceScriptLine, set) retain ];

        if ( [ elements containsObject:@"uses" ] == YES || [ elements containsObject:@"set" ] == YES )
        {
            [ validLines addObject:materialInstanceScriptLine ];
        }

        [ elements release ];
    }

    [ materialInstanceScript release ];
    materialInstanceScript = validLines;
}

- (void) filterTextureNamesNotUsedInEffect
{
    NSMutableDictionary * validTextureNameToTextureFileName = [[ NSMutableDictionary alloc ] init ];
    NpDefaultSemantics * effectSemantics = [ effect defaultSemantics ];

    NSEnumerator * enumerator = [ textureNameToTextureFileName keyEnumerator ];
    NSString * textureName;

    while ( ( textureName = [ enumerator nextObject ] ) )
    {
        Int i = 0;
        while ( effectSemantics->sampler[i] != NULL )
        {
            NSString * parameterName = [ [ NSString alloc ] initWithFormat:@"%s", cgGetParameterName(effectSemantics->sampler[i]) ];

            if ( [ textureName isEqual:parameterName ] == YES )
            {
                [ validTextureNameToTextureFileName setObject:[textureNameToTextureFileName objectForKey:textureName] forKey:textureName ];
            }

            [ parameterName release ];

            i++;
        }
    }

    [ textureNameToTextureFileName release ];
    textureNameToTextureFileName = validTextureNameToTextureFileName;

}

- (void) parseMaterialInstanceScriptLines
{
    NSMutableDictionary * textureFileNameToTextureName = [ [ NSMutableDictionary alloc ] init ];
    NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];

    NSEnumerator * enumerator = [ materialInstanceScript objectEnumerator ];
    NSString * materialInstanceScriptLine;

    while ( (materialInstanceScriptLine = [ enumerator nextObject ]) )
    {
        NSMutableArray * elements = [ splitStringUsingCharacterSet(materialInstanceScriptLine, set) retain ];

        NSString * firstElement = [ elements objectAtIndex:0 ];
        NSString * secondElement = [ elements objectAtIndex:1 ];

        if ( [ firstElement isEqual:@"uses" ] == YES )
        {
            NSString * fileNameWithoutQuotes =  [ removeLeadingAndTrailingQuotes(secondElement) retain ];
            NPLOG(([NSString stringWithFormat:@"CgFX file: %@", fileNameWithoutQuotes]));

            effect = [[[ NPEngineCore instance ] effectManager ] loadEffectFromPath:fileNameWithoutQuotes ];

            [ fileNameWithoutQuotes release ];
        }
        else if ( [ firstElement isEqual:@"set" ] == YES )
        {
            if ( [ secondElement isEqual:@"technique" ] == YES )
            {
                NSString * techniqueNameWithoutQuotes =  [ removeLeadingAndTrailingQuotes([ elements objectAtIndex:2 ]) retain ];
                NPLOG(([NSString stringWithFormat:@"Technique: %@", techniqueNameWithoutQuotes]));

                CGtechnique technique = cgGetNamedTechnique([effect effect],[techniqueNameWithoutQuotes cStringUsingEncoding:NSASCIIStringEncoding]);
                [ effect setDefaultTechnique:technique];

                [ techniqueNameWithoutQuotes release ];
            }
            else if ( [ secondElement isEqual:@"texture2D" ] == YES )
            {
                NSString * textureName = [ removeLeadingAndTrailingQuotes([ elements objectAtIndex:2 ]) retain ];
                NPLOG(([NSString stringWithFormat:@"TextureName: %@", textureName]));

                NSString * textureFileName = [ removeLeadingAndTrailingQuotes([ elements objectAtIndex:3 ]) retain ];
                NPLOG(([NSString stringWithFormat:@"TextureFileName: %@", textureFileName]));

                [ textureNameToTextureFileName setObject:textureFileName forKey:textureName];

                [ textureFileName release ];
                [ textureName release ];
            }
        }
    }
}

/*- (void) loadTextures:(NSDictionary *)textureFileNameToTextureName
{
    NSEnumerator * enumerator = [ textureFileNameToTextureName objectEnumerator ];
    NSString * textureFileName;

    while ( ( textureFileName = [ enumerator nextObject ] ) )
    {
        NPTexture * texture = [[[ NPEngineCore instance ] textureManager ] loadTextureFromPath:textureFileName ];
        [ textures addObject:texture ];
    }
}*/

- (BOOL) parseMaterialInstanceScript
{
    [ self removeInvalidLinesFromMaterialInstanceScript ];
    [ self parseMaterialInstanceScriptLines ];

    if ( effect == nil )
    {
        return NO;
    }

    [ self filterTextureNamesNotUsedInEffect ];
    NPLOG(([NSString stringWithFormat:@"%@", [ textureNameToTextureFileName description ]]));

    //[ self loadTextures:validTextureFileNameToTextureName ];

    return YES;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * materialInstanceName = [ file readSUXString ];
    [ self setName:materialInstanceName ];
    [ materialInstanceName release ];
    NPLOG(([NSString stringWithFormat:@"Material Instance Name: %@", name]));

    NSString * materialScriptFileName = [ file readSUXString ];
    [ self setMaterialFileName:materialScriptFileName ];
    [ materialScriptFileName release ];
    NPLOG(([NSString stringWithFormat:@"Material Script File: %@", materialFileName]));

    materialInstanceScript = [ file readSUXScript ];

    BOOL parseSucces = [ self parseMaterialInstanceScript ];

    ready = YES;

    return YES;
}

- (void) reset
{
    [ materialFileName release ];
    materialFileName = @"";

    [ materialInstanceScript removeAllObjects ];

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

@end
