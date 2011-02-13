#import "NPEffectTechniqueVariable.h"

@implementation NPEffectTechniqueVariable

- (id) init
{
    return [ self initWithName:@"Effect Technique Variable" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName
                        parent:newParent
                      location:INT_MAX ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
           location:(GLint)newLocation
{
    self = [ super initWithName:newName parent:newParent ];

    location = newLocation;

    return self;
}

- (GLint) location
{
    return location;
}

@end

