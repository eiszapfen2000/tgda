#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface RTVMenu : NPObject
{
    FMatrix4 * projection;
    FMatrix4 * identity;

    id menuAction;
    BOOL menuActive;
    Float blendTime;
    Float currentBlendTime;
    Float blendStartTime;

    id menuEffect;
    CGparameter scale;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) update:(Float)frameTime;
- (void) render;

@end
