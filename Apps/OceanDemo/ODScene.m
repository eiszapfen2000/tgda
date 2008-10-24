#import "NP.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    movement.moveForward  = 0;
    movement.moveBackward = 0;
    movement.strafeLeft   = 0;
    movement.strafeRight  = 0;

    return self;
}

- (void) dealloc
{
    [ skybox    release ];
    [ projector release ];
    [ camera    release ];
    [ surface   release ];

    [ skyboxStateSet dealloc ];

    [ super dealloc ];
}

- (void) setup
{
    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos;
    V_X(pos) = 0.0f;
    V_Y(pos) = 2.0f;
    V_Z(pos) = 5.0f;

    [ camera setPosition:&pos ];
    //[ camera cameraRotateUsingYaw:0.0f andPitch:-30.0f ];

    V_Y(pos) = 3.0f;
    V_Z(pos) = 0.0f;

    [ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:0.0f andPitch:-30.0f ];
    [ projector setRenderFrustum:YES ];

    skybox = [[[[ NP Graphics ] modelManager ] loadModelFromPath:@"skybox.model" ] retain];
    //skyboxStateSet = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:@"skybox.stateset" ];

    NPEffect * effect  = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"skybox.cgfx" ];
    NPEffect * effect2 = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"test.cgfx" ];
    //[ effect release ];
    //NPSUXModel * brak = [[[[ NP Graphics ] modelManager ] loadModelFromPath:@"skybox2.model" ] retain];


    //[ skybox uploadToGL ];

    IVector2 res;
    res.x = res.y = 4;
    surface = [[ ODSurface alloc ] initWithName:@"WaterSurface" parent:self resolution:&res ];

}

- (ODSurface *) surface
{
    return surface;
}

- (ODCamera *) camera
{
    return camera;
}

- (ODProjector *) projector
{
    return projector;
}

- (void) activateForwardMovement
{
    movement.moveForward  = 1;
}

- (void) deactivateForwardMovement
{
    movement.moveForward  = 0;
}

- (void) activateBackwardMovement
{
    movement.moveBackward = 1;
}

- (void) deactivateBackwardMovement
{
    movement.moveBackward = 0;
}

- (void) activateStrafeLeft
{
    movement.strafeLeft = 1;
}

- (void) deactivateStrafeLeft
{
    movement.strafeLeft = 0;
}

- (void) activateStrafeRight
{
    movement.strafeRight = 1;
}

- (void) deactivateStrafeRight
{
    movement.strafeRight = 0;
}

- (void) cameraRotateUsingYaw:(Float)yaw andPitch:(Float)pitch
{
    [ camera cameraRotateUsingYaw:-yaw*0.2f andPitch:pitch*0.2f ];
}

- (void) update
{
    if ( movement.moveForward  == 1 )
    {[ camera moveForward];}

    if ( movement.moveBackward  == 1 )
    {[ camera moveBackward];}

    if ( movement.strafeLeft  == 1 )
    {[ camera moveLeft];}

    if ( movement.strafeRight  == 1 )
    {[ camera moveRight];}

    [ camera    update ];
    [ projector update ];
    [ surface   update ];
}

- (void) render
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    [ camera render ];
    [ projector render ];

    //[ skyboxStateSet activate ];
    //[ skybox render ];

    [ surface render ];

    

    GLenum error;
    error = glGetError();

    if ( error != GL_NO_ERROR )
    {
        NPLOG_ERROR(([NSString stringWithFormat:@"%s",gluErrorString(error)]));
    }

    [[[[ NP Graphics ] renderContextManager ] currentRenderContext ] swap ];
}

@end
