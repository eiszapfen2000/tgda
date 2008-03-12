#import "NPCamera.h"

@implementation NPCamera

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NP Camera" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    view = fm4_alloc();
    projection = fm4_alloc();

    orientation = quat_alloc();
    position = v3_alloc();

    [ self reset ];

    return self;
}

- (void) reset
{
    fieldOfView = 45.0f;
    aspectRatio = 1.0f;
    nearPlane = 0.5f;
    farPlane = 100.0f;

    v3_v_zeros(position);

    [ self resetMatrices ];
    [ self resetOrientation ];
}

- (void) resetMatrices
{
    fm4_set_identity(view);
    fm4_set_identity(projection);
}

- (void) resetOrientation
{
    quat_set_identity(orientation);
}

- (FMatrix4 *) view
{
    return view;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (void) rotateX:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        Double degrees = -degrees;
        quat_q_rotatex(orientation, &degrees);
    }
}

- (void) rotateY:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        degrees = -degrees;
        quat_q_rotatey(orientation, &degrees);
    }
}

- (void) rotateZ:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        degrees = -degrees;
        quat_q_rotatez(orientation, &degrees);
    }
}

- (Vector3 *) position
{
    return position;
}

- (void) setPosition:(Vector3 *)newPosition
{
    V_X(*position) = V_X(*newPosition);    
    V_Y(*position) = V_Y(*newPosition);
    V_Z(*position) = V_Z(*newPosition);
}


@end
