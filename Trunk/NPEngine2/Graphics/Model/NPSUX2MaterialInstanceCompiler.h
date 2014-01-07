#import "Core/String/NPParser.h"

@class NPStringList;
@class NPSUX2MaterialInstance;

@interface NPSUX2MaterialInstanceCompiler : NPParser
{
    NPSUX2MaterialInstance * instanceToCompile;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) compileScript:(NPStringList *)script
  intoMaterialInstance:(NPSUX2MaterialInstance *)materialInstance
                      ;

@end
