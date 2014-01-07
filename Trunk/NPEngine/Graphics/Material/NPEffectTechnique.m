#import "NPEffectTechnique.h"

@implementation NPEffectTechnique

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPEffectTechnique" parent:newParent ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:newParent technique:NULL ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
          technique:(CGtechnique)newTechnique
{
    self = [ super initWithName:newName parent:newParent ];

    technique = newTechnique;

    return self;    
}

- (CGpass) firstPass
{
    return cgGetFirstPass(technique);
}

@end

