#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Core/String/NPStringList.h"
#import "Core/String/NPParser.h"
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPEffectVariable.h"
#import "NPEffectTechnique.h"
#import "NPEffect.h"


@interface NPEffect (Private)

- (void) parseHeader:(NPParser *)parser;
- (void) parseTechniques:(NPParser *)parser
              withScript:(NPStringList *)script
                        ;

@end

@implementation NPEffect (Private)

- (void) parseHeader:(NPParser *)parser
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for (NSUInteger i = 0; i < numberOfLines; i++)
    {
        NSString * effectName = nil;

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"effect" ] == YES
             && [ parser getTokenAsString:&effectName fromLine:i atPosition:1 ] == YES
             && [ parser isTokenFromLine:i atPosition:2 equalToString:@":" ] == YES )
        {
            [ self setName:effectName ];

            break;
        }
    }
}

- (void) parseTechniques:(NPParser *)parser
              withScript:(NPStringList *)script
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines - 2; i++ )
    {
        NSString * techniqueName = nil;
        NSRange lineRange = NSMakeRange(ULONG_MAX, 0);

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"technique" ] == YES
             && [ parser getTokenAsString:&techniqueName fromLine:i atPosition:1 ] == YES
             && [ parser isTokenFromLine:i+1 atPosition:0 equalToString:@"{" ] == YES )
        {
            NSUInteger nestingLevel = 0;

            // inside technique, find end
            for (NSUInteger j = i + 2; j < numberOfLines; j++)
            {
                // another opening brace
                if ( [ parser isTokenFromLine:j atPosition:0 equalToString:@"{" ] == YES )
                {
                    nestingLevel++;
                    continue;
                }

                if ( [ parser isTokenFromLine:j atPosition:0 equalToString:@"}" ] == YES )
                {
                    if ( nestingLevel != 0 )
                    {
                        nestingLevel--;
                        continue;
                    }

                    lineRange.location = i + 2;
                    lineRange.length = j - ( i + 2 );

                    NPStringList * techniqueStringList
                        = [ script stringListInRange:lineRange ];

                    NPEffectTechnique * technique
                        = AUTORELEASE([[ NPEffectTechnique alloc ]
                                             initWithName:techniqueName
                                                   effect:self ]);

                    NSError * error = nil;
                    if ( [ technique loadFromStringList:techniqueStringList
                                                  error:&error ] == YES )
                    {
                        [ techniques addObject:technique ];
                    }
                    else
                    {
                        NPLOG_ERROR(error);
                    }

                    // exit the inner loop since we are
                    // done with the technique
                    break;
                }
            }
        }
    }
}

@end

@implementation NPEffect

- (id) init
{
    return [ self initWithName:@"Effect" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];
    [[[ NPEngineGraphics instance ] effects ] registerAsset:self ];

    file = nil;
    ready = NO;
    techniques = [[ NSMutableArray alloc ] init ];
    variables =  [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ self clear ];
    DESTROY(techniques);
    DESTROY(variables);
    [[[ NPEngineGraphics instance ] effects ] unregisterAsset:self ];

    [ super dealloc ];
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;
    [ techniques removeAllObjects ];
    [ variables  removeAllObjects ];
}

- (id) variableWithName:(NSString *)variableName
{
    return [ variables objectWithName:variableName ];
}

- (id) variableAtIndex:(NSUInteger)index
{
    return [ variables objectAtIndex:index ];
}

- (NPEffectTechnique *) techniqueWithName:(NSString *)techniqueName
{
    return [ techniques objectWithName:techniqueName ];
}

- (NPEffectTechnique *) techniqueAtIndex:(NSUInteger)index
{
    return [ techniques objectAtIndex:index ];
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
    [ self clear ];

    NPStringList * effectScript
        = AUTORELEASE([[ NPStringList alloc ]
                            initWithName:@""
                         allowDuplicates:YES
                       allowEmptyStrings:NO ]);

    if ( [ effectScript loadFromStream:stream error:error ] == NO )
    {
        return NO;
    }

    return [ self loadFromStringList:effectScript error:error ];
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    [ self clear ];

    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"Loading effect \"%@\"", completeFileName);

    NPStringList * effectScript
        = AUTORELEASE([[ NPStringList alloc ]
                            initWithName:@"" 
                         allowDuplicates:YES
                       allowEmptyStrings:NO ]);

    if ( [ effectScript loadFromFile:completeFileName
                           arguments:nil
                               error:error ] == NO )
    {
        return NO;
    }

    return [ self loadFromStringList:effectScript error:error ];
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    NPStringList * stringListCopy
         = [ NPStringList stringListWithStringList:stringList ];

    [ stringListCopy removeStringsWithPrefix:@"#"];

    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:stringListCopy ];

    [ self parseHeader:parser ];
    [ self parseTechniques:parser withScript:stringListCopy ];

    DESTROY(parser);

    if ( [ techniques count ] != 0 )
    {
        ready = YES;
    }

    return YES;
}

@end
