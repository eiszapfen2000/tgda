#import "NPPolygonFillState.h"

@implementation NPPolygonFillState

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName configuration:newConfiguration ];

    frontFaceFill        = NpPolygonFillFace;
    defaultFrontFaceFill = NpPolygonFillFace;
    currentFrontFaceFill = NpPolygonFillLine;

    backFaceFill        = NpPolygonFillFace;
    defaultBackFaceFill = NpPolygonFillFace;
    currentBackFaceFill = NpPolygonFillLine;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NpPolygonFillMode) frontFaceFill
{
    return frontFaceFill;
}

- (NpPolygonFillMode) defaultFrontFaceFill
{
    return defaultFrontFaceFill;
}

- (NpPolygonFillMode) backFaceFill
{
    return backFaceFill;
}

- (NpPolygonFillMode) defaultBackFaceFill
{
    return defaultBackFaceFill;
}

- (void) setFrontFaceFill:(NpPolygonFillMode)newFrontFaceFill
{
    if ( [ super changeable ] == YES )
    {
        frontFaceFill = newFrontFaceFill;
    }
}

- (void) setDefaultFrontFaceFill:(NpPolygonFillMode)newDefaultFrontFaceFill
{
    defaultFrontFaceFill = newDefaultFrontFaceFill;
}

- (void) setBackFaceFill:(NpPolygonFillMode)newBackFaceFill
{
    if ( [ super changeable ] == YES )
    {
        backFaceFill = newBackFaceFill;
    }
}

- (void) setDefaultBackFaceFill:(NpPolygonFillMode)newDefaultBackFaceFill
{
    defaultBackFaceFill = newDefaultBackFaceFill;
}

- (void) activate
{
    if ( [ super changeable ] == NO )
    {
         return;
    }

    GLenum mode;
    //if ( currentFrontFaceFill != frontFaceFill )
    {
        currentFrontFaceFill = frontFaceFill;

        mode = getGLPolygonFillMode(frontFaceFill);
        glPolygonMode(GL_FRONT, mode);
    }

    //if ( currentBackFaceFill != backFaceFill )
    {
        currentBackFaceFill  = backFaceFill;

        mode = getGLPolygonFillMode(frontFaceFill);
        glPolygonMode(GL_BACK,mode);
    }

}

- (void) deactivate
{
    if ( [ super changeable ] == YES )
    {
        [ self reset ];
        [ self activate ];
    }
}

- (void) reset
{
    if ( [ super changeable ] == YES )
    {
        frontFaceFill = defaultFrontFaceFill;
        backFaceFill  = defaultBackFaceFill;
    }
}


@end
