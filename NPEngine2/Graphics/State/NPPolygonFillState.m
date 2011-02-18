#import "NPPolygonFillState.h"
#import "NP.h"

@implementation NPPolygonFillState

- (id) init
{
    return [ self initWithName:@"NP Polygon Fill State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:newParent configuration:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName parent:newParent configuration:newConfiguration ];

    frontFaceFill        = NP_POLYGON_FILL_FACE;
    defaultFrontFaceFill = NP_POLYGON_FILL_FACE;
    currentFrontFaceFill = NP_POLYGON_FILL_LINE;

    backFaceFill        = NP_POLYGON_FILL_FACE;
    defaultBackFaceFill = NP_POLYGON_FILL_FACE;
    currentBackFaceFill = NP_POLYGON_FILL_LINE;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NpState) frontFaceFill
{
    return frontFaceFill;
}

- (void) setFrontFaceFill:(NpState)newFrontFaceFill
{
    if ( [ super changeable ] == YES )
    {
        frontFaceFill = newFrontFaceFill;
    }
}

- (NpState) defaultFrontFaceFill
{
    return defaultFrontFaceFill;
}

- (void) setDefaultFrontFaceFill:(NpState)newDefaultFrontFaceFill
{
    defaultFrontFaceFill = newDefaultFrontFaceFill;
}

- (NpState) backFaceFill
{
    return backFaceFill;
}

- (void) setBackFaceFill:(NpState)newBackFaceFill
{
    if ( [ super changeable ] == YES )
    {
        backFaceFill = newBackFaceFill;
    }
}

- (NpState) defaultBackFaceFill
{
    return defaultBackFaceFill;
}

- (void) setDefaultBackFaceFill:(NpState)newDefaultBackFaceFill
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

        switch ( frontFaceFill )
        {
            case NP_POLYGON_FILL_POINT: { mode = GL_POINT; break; }
            case NP_POLYGON_FILL_LINE : { mode = GL_LINE;  break; }
            case NP_POLYGON_FILL_FACE : { mode = GL_FILL;  break; }
            default: { NPLOG_ERROR(@"Unknown polygon mode"); return; }
        }

        glPolygonMode(GL_FRONT,mode);
    }

    //if ( currentBackFaceFill != backFaceFill )
    {
        currentBackFaceFill  = backFaceFill;

        switch ( backFaceFill )
        {
            case NP_POLYGON_FILL_POINT: { mode = GL_POINT; break; }
            case NP_POLYGON_FILL_LINE : { mode = GL_LINE;  break; }
            case NP_POLYGON_FILL_FACE : { mode = GL_FILL;  break; }
            default: { NPLOG_ERROR(@"Unknown polygon mode"); return; }
        }

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
