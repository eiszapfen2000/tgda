#import "Core/NPObject/NPObject.h"
#import "NPEngineGraphicsEnums.h"

@interface NPEngineGraphicsStringToClassConversion : NPObject
{
}

- (id) initWithName:(NSString *)newName;

- (Class) classForUniformType:(NSString *)uniformType;

@end
