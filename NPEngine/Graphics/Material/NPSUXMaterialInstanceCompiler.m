#import "NPSUXMaterialInstance.h"
#import "NPSUXMaterialInstanceCompiler.h"
#import "NP.h"

@implementation NPSUXMaterialInstanceCompiler

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPSUXMaterialInstanceCompiler" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

- (void) dealloc
{
	[ super dealloc ];
}

- (void) parseUsesStatement:(NSUInteger)lineIndex
{
    NSString * effectFileName = nil;

    if ( [ self getTokenAsString:&effectFileName
                        fromLine:lineIndex
                      atPosition:1 ] == YES )
    {
        [ materialInstanceToCompile addEffectFromPath:effectFileName ];
    }
}

- (void) parseSetStatement:(NSUInteger)lineIndex
{
    NSString * token = nil;

    if ( [ self getTokenAsLowerCaseString:&token
                                 fromLine:lineIndex
                               atPosition:1 ] == YES )
    {
        if ( [ token isEqual:@"technique" ] == YES )
        {
            NSString * techniqueName = nil;

            if ( [ self getTokenAsString:&techniqueName
                                 fromLine:lineIndex
                               atPosition:2 ] == YES )
            {
                [ materialInstanceToCompile setEffectTechniqueByName:techniqueName ];
            }
        }
        else
        {
            BOOL sRGB = NO;
            NSRange range = [ token rangeOfString:@"sRGB" ];
            if ( range.location != NSNotFound )
            {
                sRGB = YES;
            }

            NSString * textureVariableName = nil;
            NSString * textureFileName = nil;

            BOOL foundTextureVariableName = 
                    [ self getTokenAsString:&textureVariableName
                                   fromLine:lineIndex
                                 atPosition:2 ];

            BOOL foundTextureFileName = 
                     [ self getTokenAsString:&textureFileName
                                    fromLine:lineIndex
                                  atPosition:3 ];

            if ( (foundTextureVariableName == YES) && (foundTextureFileName == YES) )
            {
                if ( ([ token isEqual:@"texture1d" ] == YES) ||
                     ([ token isEqual:@"texture1dsrgb" ] == YES) )
                {

                }
                else if ( ([ token isEqual:@"texture2d" ] == YES) ||
                          ([ token isEqual:@"texture2Dsrgb" ] == YES) )
                {
                    [ materialInstanceToCompile addTexture2DWithName:textureVariableName
                                                            fromPath:textureFileName
                                                                sRGB:sRGB ];
                }
                /*
                else if ( [ token isEqual:@"texture3D" ] == YES )
                {
                }
                else if ( [ token isEqual:@"textureCUBE" ] == YES ||
                          [ token isEqual:@"textureCUBEsRGB" ] == YES )
                {
                }
                */
            }
        }
    }   
}

- (void) parseStatements
{
    for (NSUInteger i = 0; i < [ lines count ]; i++ )
    {
        NSString * token = nil;

        if ( [ self getTokenAsLowerCaseString:&token
                                     fromLine:i
                                   atPosition:0 ] == YES )
        {
            if ( [ token isEqual:@"set" ] == YES )
            {
                [ self parseSetStatement:i ];
            }
            else if ( [ token isEqual:@"uses" ] == YES )
            {
                [ self parseUsesStatement:i ];
            }
        }
    }
}

- (void) compileInformationFromScript:(NPStringList *)inputScript
              intoSUXMaterialInstance:(NPSUXMaterialInstance *)materialInstance
{
    if ( materialInstance == nil )
    {
        NPLOG_ERROR(@"No target material instance supplied");
        return;
    }

    if ( inputScript == nil )
    {
        NPLOG_ERROR(@"No input script supplied");
        return;
    }

    materialInstanceToCompile = [ materialInstance retain ];

    [ self parse:inputScript ];
    [ self parseStatements ];

    DESTROY(materialInstanceToCompile);

}

@end
