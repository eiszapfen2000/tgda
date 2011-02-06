#import <Foundation/NSException.h>
#import "NPEffect.h"
#import "NPEffectTechnique.h"
#import "NPEffectCompiler.h"

@interface NPEffectCompiler (Private)

- (void) parseHeader;
- (void) parseSetShaderStatement:(const NSUInteger)lineIndex;
- (void) parseSetStatement:(const NSUInteger)lineIndex;
- (void) parseTechnique:(NPEffectTechnique *)technique inRange:(const NSRange)range;
- (void) parseTechniques;

@end

@implementation NPEffectCompiler

- (void) compileScript:(NPStringList *)inputScript
            intoEffect:(NPEffect *)targetEffect
{
    NSAssert(inputScript != nil && targetEffect != nil, @"");

    ASSIGN(effect, targetEffect);
    [ self parse:inputScript ];

    [ self parseHeader ];
    [ self parseTechniques ];

    DESTROY(effect);
}

@end

@implementation NPEffectCompiler (Private)

- (void) parseHeader
{
    NSUInteger numberOfLines = [ lines count ];
    for (NSUInteger i = 0; i < numberOfLines; i++)
    {
        NSString * effectName = nil;

        if ( [ self isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"effect" ] == YES
             && [ self getTokenAsString:&effectName fromLine:i atPosition:1 ] == YES
             && [ self isTokenFromLine:i atPosition:2 equalToString:@":" ] == YES )
        {
            [ effect setName:effectName ];
            break;
        }
    }
}

- (void) parseSetShaderStatement:(const NSUInteger)lineIndex
{
    NSString * shaderType = nil;
    NSString * shaderFileName = nil;

    if ( [ self getTokenAsLowerCaseString:&shaderType fromLine:lineIndex atPosition:1 ] == YES
         && [ self getTokenAsString:&shaderFileName fromLine:lineIndex atPosition:3 ] == YES )
    {
        if ( [ shaderType isEqual:@"vertex" ] == YES )
        {
            [ techniqueToParse addVertexShaderFromFile:shaderFileName ];
        }

        if ( [ shaderType isEqual:@"fragment" ] == YES )
        {
            [ techniqueToParse addFragmentShaderFromFile:shaderFileName ];
        }

    }
    
}

- (void) parseSetStatement:(const NSUInteger)lineIndex
{
    if ( [ self isLowerCaseTokenFromLine:lineIndex
                              atPosition:2
                           equalToString:@"shader" ] == YES )
	{
        [ self parseSetShaderStatement:lineIndex ];
    }
}

- (void) parseTechnique:(NPEffectTechnique *)technique
                inRange:(const NSRange)range
{
    NSAssert(technique != nil, @"Invalid technique");

    techniqueToParse = RETAIN(technique);

    for ( NSUInteger i = range.location;
          i < range.location + range.length; i++ )
    {
        if ( [ self isLowerCaseTokenFromLine:i 
                                  atPosition:0
                               equalToString:@"set" ] == YES )
        {
            [ self parseSetStatement:i ];
        }
    }

    DESTROY(techniqueToParse);
}

- (void) parseTechniques
{
    NSRange lineRange = NSMakeRange(ULONG_MAX, 0);

    NSUInteger numberOfLines = [ lines count ];
    for (NSUInteger i = 0; i < numberOfLines - 2; i++)
    {
        NSString * techniqueName = nil;

        if ( [ self isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"technique" ] == YES
             && [ self getTokenAsString:&techniqueName fromLine:i atPosition:1 ] == YES
             && [ self isTokenFromLine:i+1 atPosition:0 equalToString:@"{" ] == YES )
        {
            // inside technique, find end
            for (NSUInteger j = i + 2; j < numberOfLines; j++)
            {
                if ( [ self isTokenFromLine:j atPosition:0 equalToString:@"}" ] == YES )
                {
                    lineRange.location = i + 2;
                    lineRange.length = j - ( i + 2 );

                    // technique needs at least two lines, specifiying vertex
                    // and fragment shader
                    if ( lineRange.length >= 2 )
                    {
                        NPEffectTechnique * t
                            = [ effect addTechniqueWithName:techniqueName ];

                        [ self parseTechnique:t inRange:lineRange ];

                        // exit the inner loop since we are
                        // done with the technique
                        break;
                    }
                }
            }
        }
    }

}

@end

