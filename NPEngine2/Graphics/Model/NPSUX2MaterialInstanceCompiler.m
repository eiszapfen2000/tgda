#import <Foundation/NSException.h>
#import "Core/String/NPStringList.h"
#import "NPSUX2MaterialInstance.h"
#import "NPSUX2MaterialInstanceCompiler.h"

@interface NPSUX2MaterialInstanceCompiler (Private)

- (void) parseUsesStatement:(NSUInteger)lineIndex;
- (void) parseSetStatement:(NSUInteger)lineIndex;
- (void) parseStatements;

@end

@implementation NPSUX2MaterialInstanceCompiler (Private)

- (void) parseUsesStatement:(NSUInteger)lineIndex
{
    NSString * effectFileName = nil;

    if ( [ self getTokenAsString:&effectFileName
                        fromLine:lineIndex
                      atPosition:1 ] == YES )
    {
        NSLog(effectFileName);

        NSString * effectFileNameWithoutExtension
            = [ effectFileName stringByDeletingPathExtension ];

        NSString * effectFileNameWithExtension
            = [ effectFileNameWithoutExtension
                    stringByAppendingPathExtension:@"effect" ];

        [ instanceToCompile addEffectFromFile:effectFileNameWithExtension ];
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
                [ instanceToCompile setTechniqueName:techniqueName ];
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
                if ( ([ token isEqual:@"texture2d" ] == YES) ||
                     ([ token isEqual:@"texture2Dsrgb" ] == YES) )
                {
                    NSLog(@"%@ %@", textureVariableName, textureFileName);

                    [ instanceToCompile 
                        addTexture2DWithName:textureVariableName
                                    fromFile:textureFileName
                                        sRGB:sRGB ];
                }
            }
        }
    }   
}

- (void) parseStatements
{
    NSUInteger numberOfLines = [ lines count ];
    for (NSUInteger i = 0; i < numberOfLines; i++ )
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

@end

@implementation NPSUX2MaterialInstanceCompiler

- (id) init
{
    return [ self initWithName:@"SUX2 Material Instance Compiler" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ super initWithName:newName ];
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) compileScript:(NPStringList *)script
  intoMaterialInstance:(NPSUX2MaterialInstance *)materialInstance
{
    NSAssert(script != nil, @"");
    NSAssert(materialInstance != nil, @"");

    instanceToCompile = RETAIN(materialInstance);

    [ self parse:script ];
    [ self parseStatements ];

    DESTROY(instanceToCompile);
}

@end
