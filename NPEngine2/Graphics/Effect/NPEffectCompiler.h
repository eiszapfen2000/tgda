#import "Core/String/NPParser.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPStringList;

@interface NPEffectCompiler : NPParser
{
    NPEffect * effect;
    NPEffectTechnique * techniqueToParse;
}

- (void) compileScript:(NPStringList *)inputScript
            intoEffect:(NPEffect *)targetEffect
                      ;

@end
