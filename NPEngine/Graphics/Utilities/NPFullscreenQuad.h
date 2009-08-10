#import "Core/Math/FRectangle.h"
#import "Core/NPObject/NPObject.h"

@interface NPFullscreenQuad : NPObject
{
    FRectangle * positions;
    FRectangle * textureCoordinates;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setupGeometryUsingAspectRatio:(Float)aspectRatio
                  minTextureCoordinate:(FVector2)minTextureCoordinate
                  maxTextureCoordinate:(FVector2)maxTextureCoordinate
                                      ;

@end
