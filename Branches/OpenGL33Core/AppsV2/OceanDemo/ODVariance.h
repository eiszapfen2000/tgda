#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "GL/glew.h"

@class NPEffect;

@interface ODVariance : NPObject
{
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
			 effect:(NPEffect *)newEffect
			 	   ;

- (void) dealloc;

@end
