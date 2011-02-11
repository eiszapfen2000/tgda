#import <Foundation/NSException.h>
#import "Core/String/NPStringList.h"
#import "Core/String/NPParser.h"
#import "Core/Container/NPAssetArray.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPShader.h"
#import "NPEffect.h"
#import "NPEffectTechnique.h"

@interface NPEffectTechnique (Private)

- (void) addVertexShaderFromFile:(NSString *)fileName;
- (void) addFragmentShaderFromFile:(NSString *)fileName;
- (void) parseVariables:(NPParser *)parser;
- (void) parseShader:(NPParser *)parser;

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
    [ super dealloc ];
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    NSAssert(parent != nil, @"Technique does not belong to an effect");

    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:stringList ];

    [ self parseShader:parser ];

    DESTROY(parser);

    return YES;
}

@end

@implementation NPEffectTechnique (Private)

- (void) addVertexShaderFromFile:(NSString *)fileName
{
    SAFE_DESTROY(vertexShader);
    vertexShader = [[[ NPEngineGraphics instance ] shader ] getAssetWithFileName:fileName ];
}

- (void) addFragmentShaderFromFile:(NSString *)fileName
{
    SAFE_DESTROY(fragmentShader);
    fragmentShader = [[[ NPEngineGraphics instance ] shader ] getAssetWithFileName:fileName ];
}

- (void) parseVariables:(NPParser *)parser
{

}

- (void) parseShader:(NPParser *)parser
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
                [ self addVertexShaderFromFile:shaderFileName ];
            }

            if ( [ shaderType isEqual:@"fragment" ] == YES )
            {
                [ self addFragmentShaderFromFile:shaderFileName ];
            }
        }
    }
}

@end


