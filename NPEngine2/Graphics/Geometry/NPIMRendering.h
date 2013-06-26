#import "Core/Math/FRectangle.h"
#import "Core/Math/IRectangle.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@interface NPIMRendering : NSObject

+ (void) renderFRectangle:(const FRectangle)rectangle
            primitiveType:(const NpPrimitveType)primitiveType
                         ;

+ (void) renderFRectangle:(const FRectangle)rectangle
                texCoords:(const FRectangle)texCoords
            primitiveType:(const NpPrimitveType)primitiveType
                         ;

@end
