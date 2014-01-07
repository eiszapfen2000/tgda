#import "Graphics/npgl.h"
#import "NPFullscreenQuad.h"

@implementation NPFullscreenQuad

- (id) init
{
    return [ self initWithName:@"NPFullscreenQuad" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    positions = frectangle_alloc_init();
    textureCoordinates = frectangle_alloc_init();

    FVector2 minTexCoord = { 0.0f, 0.0f };
    FVector2 maxTexCoord = { 1.0f, 1.0f };

    [ self setupGeometryUsingAspectRatio:1.0f
                    minTextureCoordinate:minTexCoord
                    maxTextureCoordinate:maxTexCoord ];

    return self;
}

- (void) dealloc
{
    frectangle_free(textureCoordinates);
    frectangle_free(positions);

    [ super dealloc ];
}

- (void) setupGeometryUsingAspectRatio:(Float)aspectRatio
                  minTextureCoordinate:(FVector2)minTextureCoordinate
                  maxTextureCoordinate:(FVector2)maxTextureCoordinate
{
    positions->min.x = -aspectRatio;
    positions->min.y = -1.0f;
    positions->max.x =  aspectRatio;
    positions->max.y =  1.0f;

    textureCoordinates->min = minTextureCoordinate;
    textureCoordinates->max = maxTextureCoordinate;
}

- (void) render
{
    glBegin(GL_QUADS);
        glTexCoord2f(textureCoordinates->min.x, textureCoordinates->min.y);
        glVertex4f(positions->min.x, positions->min.y, 0.0f, 1.0f);
        glTexCoord2f(textureCoordinates->max.x, textureCoordinates->min.y);
        glVertex4f(positions->max.x, positions->min.y, 0.0f, 1.0f);
        glTexCoord2f(textureCoordinates->max.x, textureCoordinates->max.y);
        glVertex4f(positions->max.x, positions->max.y, 0.0f, 1.0f);
        glTexCoord2f(textureCoordinates->min.x, textureCoordinates->max.y);
        glVertex4f(positions->min.x, positions->max.y, 0.0f, 1.0f);
    glEnd();
}

@end
