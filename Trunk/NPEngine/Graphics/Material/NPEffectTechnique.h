#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@interface NPEffectTechnique : NPObject
{
    CGtechnique technique;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
                   ;

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
          technique:(CGtechnique)newTechnique;

- (CGpass) firstPass;

@end
