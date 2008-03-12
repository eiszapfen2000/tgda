#import "Core/NPObject/NPObject.h"

@interface NPCameraManager : NPObject
{
    NSMutableArray * cameras;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

@end
