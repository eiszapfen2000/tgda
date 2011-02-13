#import <Foundation/NSException.h>
#import <Foundation/NSIndexSet.h>
#import "Log/NPLog.h"
#import "Core/String/NPStringList.h"
#import "Core/String/NPParser.h"
#import "Core/Container/NPAssetArray.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPShader.h"
#import "NPEffect.h"
#import "NPEffectTechnique.h"

@interface NPEffectTechnique (Private)

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NSArray *)effectVariables
                                 ;

- (void) loadVertexShaderFromFile:(NSString *)fileName
                 effectVariables:(NSArray *)effectVariables
                                ;

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                   effectVariables:(NSArray *)effectVariables
                                  ;

- (NSArray *) extractEffectVariableLines:(NPStringList *)stringList;
- (void) parseShader:(NPParser *)parser
     effectVariables:(NSArray *)effectVariables
                    ;

@end

@implementation NPEffectTechnique

- (id) init
{
    return [ self initWithName:@"Technique" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    vertexShader = fragmentShader = nil;

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(vertexShader);
    SAFE_DESTROY(fragmentShader);

    [ super dealloc ];
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    NSAssert(parent != nil, @"Technique does not belong to an effect");

    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:stringList ];

    NSArray * effectVariableLines
        = [ self extractEffectVariableLines:stringList ];

    [ self parseShader:parser effectVariables:effectVariableLines ];

    DESTROY(parser);

    return YES;
}

@end

@implementation NPEffectTechnique (Private)

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NSArray *)effectVariables
{
    NSError * error = nil;
    NPStringList * shaderSource
        = [ NPStringList stringListWithContentsOfFile:fileName
                                                error:&error ];

    if ( shaderSource == nil )
    {
        NPLOG_ERROR(error);
        return nil;
    }

    [ shaderSource insertStrings:effectVariables atIndex:0 ];

    NPLOG([shaderSource description]);

    NPShader * shader
        = [ NPShader shaderFromStringList:shaderSource
                                    error:&error ];

    if ( shader == nil )
    {
        NPLOG_ERROR(error);
    }

    return shader;
}

- (void) loadVertexShaderFromFile:(NSString *)fileName
                 effectVariables:(NSArray *)effectVariables
{
    SAFE_DESTROY(vertexShader);

    NPLOG(@"Loading vertex shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables ];

    if ( shader != nil )
    {
        vertexShader = RETAIN(shader);
    }
}

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                   effectVariables:(NSArray *)effectVariables
{
    SAFE_DESTROY(fragmentShader);

    NPLOG(@"Loading fragment shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables ];

    if ( shader != nil )
    {
        fragmentShader = RETAIN(shader);
    }
}

- (NSArray *) extractEffectVariableLines:(NPStringList *)stringList
{
    NSMutableArray * lines = [ NSMutableArray arrayWithCapacity:8 ];
    [ lines addObjectsFromArray:[ stringList stringsWithPrefix:@"uniform" ]];
    [ lines addObjectsFromArray:[ stringList stringsWithPrefix:@"varying" ]];

    return [ NSArray arrayWithArray:lines ];
}

- (void) parseVariables:(NPParser *)parser
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {

    }
}

- (void) parseShader:(NPParser *)parser
     effectVariables:(NSArray *)effectVariables
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        NSString * shaderType = nil;
        NSString * shaderFileName = nil;

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"set" ] == YES
             && [ parser getTokenAsLowerCaseString:&shaderType fromLine:i atPosition:1 ] == YES
             && [ parser isLowerCaseTokenFromLine:i atPosition:2 equalToString:@"shader" ] == YES
             && [ parser getTokenAsString:&shaderFileName fromLine:i atPosition:3 ] == YES )
        {
            if ( [ shaderType isEqual:@"vertex" ] == YES )
            {
                [ self loadVertexShaderFromFile:shaderFileName
                                effectVariables:effectVariables ];
            }

            if ( [ shaderType isEqual:@"fragment" ] == YES )
            {
                [ self loadFragmentShaderFromFile:shaderFileName
                                  effectVariables:effectVariables ];
            }
        }
    }
}

@end


