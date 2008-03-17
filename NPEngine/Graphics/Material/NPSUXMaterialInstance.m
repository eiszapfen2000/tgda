#import "NPSUXMaterialInstance.h"
#import "Core/Utilities/NPStringUtilities.h"
#import "Core/NPEngineCore.h"
#import "NPEffect.h"
#import "NPEffectManager.h"

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

- (BOOL) parseCGFXFileLine:(NSArray *)lineElements
{
    if ( [ [ lineElements objectAtIndex:0 ] isEqualToString:@"uses" ] == YES )
    {
        NSString * cgfxfileName = removeLeadingAndTrailingQuotes([ lineElements objectAtIndex:1 ]);
        NSLog(cgfxfileName);
    }
    else
    {
        
    }

    return YES;
}

/*- (BOOL) parseCGFXTechniqueLine
{

}*/

- (void) removeInvalidLinesFromMaterialInstanceScript
{
    NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    NSMutableArray * validLines = [ [ NSMutableArray alloc ] init ];

    for ( Int i = 0; i < [ materialInstanceScript count ]; i++ )
    {
        NSMutableArray * elements = splitStringUsingCharacterSet([ materialInstanceScript objectAtIndex:i ], set);

        if ( [ elements containsObject:@"uses" ] == YES || [ elements containsObject:@"set" ] == YES )
        {
            [ validLines addObject:[ materialInstanceScript objectAtIndex:i ] ];
        }

        [ elements release ];
    }

    [ materialInstanceScript release ];
    materialInstanceScript = validLines;
}

- (void) parseMaterialInstanceScript
{
    [ self removeInvalidLinesFromMaterialInstanceScript ];

    NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    NSMutableArray * cgfxFileLineElements = splitStringUsingCharacterSet([ materialInstanceScript objectAtIndex:0 ], set);

    NSString * fileNameWithoutQuotes =  [ removeLeadingAndTrailingQuotes([ cgfxFileLineElements objectAtIndex:1 ]) retain ];
    NPLOG(([NSString stringWithFormat:@"CgFX file: %@", fileNameWithoutQuotes]));

    NPEffect * effect = [[[[ NPEngineCore instance ] effectManager ] loadEffectFromPath:fileNameWithoutQuotes ] retain ];

    NSMutableArray * cgfxTechniqueLineElements = splitStringUsingCharacterSet([ materialInstanceScript objectAtIndex:1 ], set);
    NSString * techniqueNameWithoutQuotes =  [ removeLeadingAndTrailingQuotes([ cgfxTechniqueLineElements objectAtIndex:2 ]) retain ];

    

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

    [ self parseMaterialInstanceScript ];

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
