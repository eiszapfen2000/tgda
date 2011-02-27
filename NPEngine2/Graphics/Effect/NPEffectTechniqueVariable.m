#import <Foundation/NSException.h>
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPEffectVariable.h"
#import "NPEffectVariableSemantic.h"
#import "NPEffectVariableSampler.h"
#import "NPEffectTechniqueVariable.h"

@implementation NPEffectTechniqueVariable

- (id) initWithName:(NSString *)newName
     effectVariable:(id)newEffectVariable
           location:(GLint)newLocation
{
    NSAssert([ newEffectVariable isKindOfClass:[ NPEffectVariable class ]] == YES, @"");

    self = [ super initWithName:newName ];

    effectVariable = newEffectVariable;
    location = newLocation;

    return self;
}

- (GLint) location
{
    return location;
}

- (void) activate
{
    [ effectVariable activate:self ];
}

@end

