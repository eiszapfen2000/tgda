#import <Foundation/NSException.h>
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPEffectVariable.h"
#import "NPEffectVariableSemantic.h"
#import "NPEffectVariableSampler.h"
#import "NPEffectTechniqueVariable.h"

@implementation NPEffectTechniqueVariable

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
     effectVariable:(id)newEffectVariable
           location:(GLint)newLocation
{
    NSAssert2((location != -1) && (newEffectVariable != nil)
             && ([ newEffectVariable isKindOfClass:[ NPEffectVariable class ]] == YES),
             @"%@ %d", newName, newLocation);

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

