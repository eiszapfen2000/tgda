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
    materialInstanceScript = nil;
    textureNameToSemantic = [[ NSMutableDictionary alloc ] init ];
    textureNameToTextureFileName = [[ NSMutableDictionary alloc ] init ];
    textureNameToTexture = [[ NSMutableDictionary alloc ] init ];
    textureToSemantic = [[ NSMutableDictionary alloc ] init ];

    effect = nil;

    return self;
}

- (void) dealloc
{
	[ materialFileName release ];
	[ materialInstanceScript release ];
    [ textureNameToSemantic removeAllObjects ];
	[ textureNameToSemantic release ];
	[ textureNameToTextureFileName removeAllObjects ];
	[ textureNameToTextureFileName release ];
	[ textureNameToTexture removeAllObjects ];
	[ textureNameToTexture release ];
	[ textureToSemantic removeAllObjects ];
	[ textureToSemantic release ];
	[ effect release ];

	[ super dealloc ];
}

- (NSString *)materialFileName
{
    return materialFileName;
}

- (void) setMaterialFileName:(NSString *)newMaterialFileName
{
    ASSIGN(materialFileName, newMaterialFileName);
}

- (void) removeInvalidLinesFromMaterialInstanceScript
{
    NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    NSMutableArray * validLines = [[ NSMutableArray alloc ] init ];

    NSEnumerator * enumerator = [ materialInstanceScript objectEnumerator ];
    NSString * materialInstanceScriptLine;

    while ( (materialInstanceScriptLine = [ enumerator nextObject ]) )
    {
        NSArray * elements = [ materialInstanceScriptLine splitUsingCharacterSet:set ];

        if ( [ elements containsObject:@"uses" ] == YES || [ elements containsObject:@"set" ] == YES )
        {
            [ validLines addObject:materialInstanceScriptLine ];
        }
    }

    ASSIGN(materialInstanceScript, validLines);
}

- (void) filterTextureNamesNotUsedInEffect
{
    NSMutableDictionary * validTextureNameToTextureFileName = [[ NSMutableDictionary alloc ] init ];
    NpDefaultSemantics * effectSemantics = [ effect defaultSemantics ];

    NSEnumerator * enumerator = [ textureNameToTextureFileName keyEnumerator ];
    NSString * textureName;

    while ( ( textureName = [ enumerator nextObject ] ) )
    {
        for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
        {
            if ( effectSemantics->sampler2D[i] != NULL )
            {
                NSString * parameterName = [ NSString stringWithFormat:@"%s", cgGetParameterName(effectSemantics->sampler2D[i]) ];

                if ( [ textureName isEqual:parameterName ] == YES )
                {
                    [ textureNameToSemantic setObject:NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(i) forKey:textureName ];
                    [ validTextureNameToTextureFileName setObject:[textureNameToTextureFileName objectForKey:textureName] forKey:textureName ];
                }
            }
        }        
    }

    ASSIGN(textureNameToTextureFileName, validTextureNameToTextureFileName);
}

- (void) parseMaterialInstanceScriptLines
{
    NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];

    NSEnumerator * enumerator = [ materialInstanceScript objectEnumerator ];
    NSString * materialInstanceScriptLine;

    while ( (materialInstanceScriptLine = [ enumerator nextObject ]) )
    {
        NSArray * elements = [ materialInstanceScriptLine splitUsingCharacterSet:set ];

        NSString * firstElement  = [ elements objectAtIndex:0 ];
        NSString * secondElement = [ elements objectAtIndex:1 ];

        if ( [ firstElement isEqual:@"uses" ] == YES )
        {
            NSString * fileNameWithoutQuotes =  [ secondElement removeLeadingAndTrailingQuotes ];
            //NPLOG(@"CgFX file: %@", fileNameWithoutQuotes);

            effect = [[[[ NP Graphics ] effectManager ] loadEffectFromPath:fileNameWithoutQuotes ] retain ];
        }
        else if ( [ firstElement isEqual:@"set" ] == YES )
        {
            if ( [ secondElement isEqual:@"technique" ] == YES )
            {
                NSString * techniqueNameWithoutQuotes =  [[ elements objectAtIndex:2 ] removeLeadingAndTrailingQuotes ];
                //NPLOG(@"Technique: %@", techniqueNameWithoutQuotes);

                NPEffectTechnique * effectTechnique = [ effect techniqueWithName:techniqueNameWithoutQuotes ];
                [ effect setDefaultTechnique:effectTechnique];
            }
            else if ( [ secondElement isEqual:@"texture2D" ] == YES )
            {
                NSString * textureName = [[ elements objectAtIndex:2 ] removeLeadingAndTrailingQuotes ];
                //NPLOG(@"TextureName: %@", textureName);

                NSString * textureFileName = [[ elements objectAtIndex:3 ] removeLeadingAndTrailingQuotes ];
                //NPLOG(@"TextureFileName: %@", textureFileName);

                [ textureNameToTextureFileName setObject:textureFileName forKey:textureName];
            }
        }
    }
}

- (void) loadTextures
{
    NSEnumerator * enumerator = [ textureNameToTextureFileName keyEnumerator ];
    NSString * textureName;

    while ( ( textureName = [ enumerator nextObject ] ) )
    {
        NPTexture * texture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:[textureNameToTextureFileName objectForKey:textureName]];
        [ textureNameToTexture setObject:texture forKey:textureName ];
    }
}

- (void) matchTexturesToSemantics
{
    NSEnumerator * enumerator = [ textureNameToTexture keyEnumerator ];
    NSString * textureName;

    while ( ( textureName = [ enumerator nextObject ] ) )
    {
        [ textureToSemantic setObject:[textureNameToTexture objectForKey:textureName] forKey:[textureNameToSemantic objectForKey:textureName] ];
    }
}

- (BOOL) parseMaterialInstanceScript
{
    [ self removeInvalidLinesFromMaterialInstanceScript ];
    [ self parseMaterialInstanceScriptLines ];

    if ( effect == nil )
    {
        return NO;
    }

    [ self filterTextureNamesNotUsedInEffect ];
    //NPLOG(@"%@", [ textureNameToTextureFileName description ]);
    //NPLOG(@"%@", [ textureNameToSemantic description ]);

    [ self loadTextures ];
    //NPLOG(@"%@", [ textureNameToTexture description ]);

    [ self matchTexturesToSemantics ];
    //NPLOG(@"%@", [ textureToSemantic description ]);

    return YES;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * materialInstanceName = [ file readSUXString ];
    [ self setName:materialInstanceName ];
    [ materialInstanceName release ];
    //NPLOG(@"Material Instance Name: %@", name);

    NSString * materialScriptFileName = [ file readSUXString ];
    [ self setMaterialFileName:materialScriptFileName ];
    [ materialScriptFileName release ];
    //NPLOG(@"Material Script File: %@", materialFileName);

    materialInstanceScript = [ file readSUXScript ];

    if ( [ self parseMaterialInstanceScript ] == YES )
    {
        ready = YES;
        return YES;
    }

    return NO;
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
    [ materialFileName release ];
    materialFileName = @"";

    [ materialInstanceScript removeAllObjects ];

    [ super reset ];
}

- (NSArray *) textures
{
    return [ textureToSemantic allValues ]; 
}

- (NPEffect *) effect
{
    return effect;
}

- (void) updateTextureBindingState
{
    NPTextureBindingState * t = [[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ];

    NSEnumerator * enumerator = [ textureToSemantic keyEnumerator ];
    NSString * semantic;

    while ( ( semantic = [ enumerator nextObject ] ) )
    {
        [ t setTexture:[textureToSemantic objectForKey:semantic] forKey:semantic ];
    }
}

- (void) activate
{
    [ self updateTextureBindingState ];

    [ effect activate ];
}

@end
