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

@implementation NPEffect

- (id) init
{
    return [ self initWithName:@"Effect" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    file = nil;
    ready = NO;
    techniques = [[ NSMutableArray alloc ] init ];
    variables =  [[ NSMutableArray alloc ] init ];

    [[[ NPEngineGraphics instance ] effects ] registerAsset:self ];

    return self;
}

- (void) dealloc
{
    [[[ NPEngineGraphics instance ] effects ] unregisterAsset:self ];

    [ self clear ];
    DESTROY(techniques);
    [ super dealloc ];
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

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;
    [ techniques removeAllObjects ];
    [ variables  removeAllObjects ];
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
                                  parent:self
                         allowDuplicates:YES
                       allowEmptyStrings:NO ]);

    if ( [ effectScript loadFromStream:stream error:error ] == NO )
    {
        return NO;
    }

    return [ self loadFromStringList:effectScript error:error ];
}

- (BOOL) loadFromFile:(NSString *)fileName
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

    NPStringList * effectScript
        = AUTORELEASE([[ NPStringList alloc ]
                            initWithName:@"" 
                                  parent:self
                         allowDuplicates:YES
                       allowEmptyStrings:NO ]);

    if ( [ effectScript loadFromFile:completeFileName 
                               error:error ] == NO )
    {
        return NO;
    }

    return [ self loadFromStringList:effectScript error:error ];
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:stringList ];

    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines - 2; i++ )
    {
        NSString * techniqueName = nil;
        NSRange lineRange = NSMakeRange(ULONG_MAX, 0);

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"technique" ] == YES
             && [ parser getTokenAsString:&techniqueName fromLine:i atPosition:1 ] == YES
             && [ parser isTokenFromLine:i+1 atPosition:0 equalToString:@"{" ] == YES )
        {
            // inside technique, find end
            for (NSUInteger j = i + 2; j < numberOfLines; j++)
            {
                if ( [ parser isTokenFromLine:j atPosition:0 equalToString:@"}" ] == YES )
                {
                    lineRange.location = i + 2;
                    lineRange.length = j - ( i + 2 );

                    NPStringList * techniqueStringList
                        = [ stringList stringListInRange:lineRange ];

                    NPEffectTechnique * technique
                        = AUTORELEASE([[ NPEffectTechnique alloc ]
                                             initWithName:techniqueName
                                                   parent:self ]);

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

    DESTROY(parser);
    return YES;
}

@end
