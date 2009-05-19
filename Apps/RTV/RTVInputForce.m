#import "NP.h"
#import "RTVScene.h"
#import "RTVAdvection.h"
#import "RTVInputForce.h"

@implementation RTVInputForce

- (id) init
{
    return [ self initWithName:@"Input Force" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    inputEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Input.cgfx" ];
    inputForceRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"InputForceRT" parent:self ];

    leftClickAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"LeftClick" primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT ];

    stateSet = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:@"input.stateset" ];

    clickPosition = [ inputEffect parameterWithName:@"clickPosition" ];
    radius        = [ inputEffect parameterWithName:@"radius" ];

    return self;
}

- (void) dealloc
{
    [ inputForceRenderTargetConfiguration clear ];
    [ inputForceRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (void) update:(Float)frameTime
{
    if ( [ leftClickAction active ] == YES )
    {
        IVector2 * controlSize = [[[ NP Graphics ] viewportManager ] currentControlSize ];

        Float mouseX = [[[ NP Input ] mouse ] x ];
        Float mouseY = [[[ NP Input ] mouse ] y ];

        FVector2 normalisedMousePosition;

        // shift to pixel center using + 0.5
        normalisedMousePosition.x = (mouseX + 0.5) / (Float)(controlSize->x);
        normalisedMousePosition.y = (mouseY + 0.5) / (Float)(controlSize->y);

        FVector2 mouseFragmentPosition;
        mouseFragmentPosition.x = mouseX + 0.5f;
        mouseFragmentPosition.y = mouseY + 0.5f;

        FVector2 preProjectionMousePosition;
        preProjectionMousePosition.x = normalisedMousePosition.x * 2.0f - 1.0f;
        preProjectionMousePosition.y = normalisedMousePosition.y * 2.0f - 1.0f;
        Float clickRadius = 20.0f;

        FVector2 upperLeft;
        FVector2 lowerRight;
        upperLeft.x  = preProjectionMousePosition.x - (clickRadius/(Float)(controlSize->x));
        upperLeft.y  = preProjectionMousePosition.y + (clickRadius/(Float)(controlSize->y));
        lowerRight.x = preProjectionMousePosition.x + (clickRadius/(Float)(controlSize->x));
        lowerRight.y = preProjectionMousePosition.y - (clickRadius/(Float)(controlSize->y));

        id velocitySource = [[(RTVScene *)parent advection ] velocitySource ];
        //id velocityTarget = [[(RTVScene *)parent advection ] velocityTarget ];

        [ inputForceRenderTargetConfiguration setColorRenderTarget:velocitySource atIndex:0 ];
        [ inputForceRenderTargetConfiguration checkFrameBufferCompleteness ];
        [ inputForceRenderTargetConfiguration activate ];

        // Activates additive blending
        [ stateSet activate ];

        id texture = [ velocitySource texture ];
        [[[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ] setTexture:texture forKey:@"NPCOLORMAP0" ];

        [ inputEffect uploadFloatParameter:radius andValue:clickRadius ];
        [ inputEffect uploadFVector2Parameter:clickPosition andValue:&mouseFragmentPosition ];
        [ inputEffect activate ];

        glBegin(GL_QUADS);
            glVertex4f(upperLeft.x , upperLeft.y , 0.0f, 1.0f);
            glVertex4f(upperLeft.x , lowerRight.y, 0.0f, 1.0f);
            glVertex4f(lowerRight.x, lowerRight.y, 0.0f, 1.0f);
            glVertex4f(lowerRight.x, upperLeft.y , 0.0f, 1.0f);
        glEnd();

        [ inputEffect deactivate ];

        [ inputForceRenderTargetConfiguration deactivate ];

        //[[(RTVScene *)parent advection ] swapVelocityRenderTextures ];
    }
}

- (void) render
{

}

@end
