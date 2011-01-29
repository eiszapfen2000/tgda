#import "Core/Utilities/NPParser.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPStringList;

@interface NPEffectCompiler : NPParser
{
    NPEffect * effect;
}

- (void) compileScript:(NPStringList *)inputScript
            intoEffect:(NPEffect *)targetEffect
                      ;

@end
