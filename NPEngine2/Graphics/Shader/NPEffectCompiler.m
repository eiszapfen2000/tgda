#import <Foundation/NSException.h>
#import "NPEffectCompiler.h"

@interface NPEffectCompiler (Private)

- (void) parseHeader;
- (void) parseTechniqueInRange:(NSRange)range;
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

- (void) parseTechniqueInRange:(NSRange)range
{
}

- (void) parseTechniques
{
}

@end

