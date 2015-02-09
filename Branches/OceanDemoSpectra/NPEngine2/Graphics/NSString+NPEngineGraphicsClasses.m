#import "NPEngineGraphics.h"
#import "NPEngineGraphicsStringToClassConversion.h"
#import "NSString+NPEngineGraphicsClasses.h"

@implementation NSString (NPEngineGraphicsClasses)

- (Class) uniformTypeClass
{
        return [[[ NPEngineGraphics instance ] stringToClassConversion ] 
                       classForUniformType:self ];
}

@end
