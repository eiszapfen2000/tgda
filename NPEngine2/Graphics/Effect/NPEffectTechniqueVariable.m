#import <Foundation/NSException.h>
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPEffectVariable.h"
#import "NPEffectVariableSemantic.h"
#import "NPEffectVariableSampler.h"
#import "NPEffectTechniqueVariable.h"

@implementation NPEffectTechniqueVariable

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
           location:(GLint)newLocation
{
    NSAssert([ newParent isKindOfClass:[ NPEffectVariable class ]] == YES, @"");

    self = [ super initWithName:newName parent:newParent ];

    location = newLocation;

    return self;
}

- (GLint) location
{
    return location;
}

- (void) activate
{
    [ parent activate:self ];
}

@end

