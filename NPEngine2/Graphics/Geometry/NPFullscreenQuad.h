#import "Core/Math/FVector.h"
#import "Core/Math/FVertex.h"
#import "Core/NPObject/NPObject.h"

@interface NPFullscreenQuad : NPObject
{
    GLuint vertexArrayID;
    GLuint vertexStreamID;
    GLuint texcoordStreamID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setupGeometryUsingAspectRatio:(const float)aspectRatio
                  minTextureCoordinate:(const FVector2)minTextureCoordinate
                  maxTextureCoordinate:(const FVector2)maxTextureCoordinate
                                      ;

- (void) render;

@end
