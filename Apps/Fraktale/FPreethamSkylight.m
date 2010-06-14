#import "NP.h"
#import "FCore.h"
#import "FScene.h"
#import "FCamera.h"
#import "FPreethamSkylight.h"


@implementation FPreethamSkylight

- (id) init
{
    return [ self initWithName:@"PreethamSkylight" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    modelMatrix = fm4_alloc_init();
    position = fv3_alloc_init();
    sunTheta = fv2_alloc_init();
    lightDirection = fv3_alloc_init_with_components(0.5f, 0.5f, 0.0f);
    zenithColor = fv3_alloc_init();
    turbidity = 3.0f;

    model    = [[[ NP Graphics ] modelManager    ] loadModelFromPath:@"sky.model" ];
    stateset = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:@"preetham.stateset" ];

    NPEffect * effect = [[[ model materials ] objectAtIndex:0 ] effect ];

    lightDirectionP = [ effect parameterWithName:@"LightDirection" ];
    thetaSunP       = [ effect parameterWithName:@"ThetaSun" ];
    zenithColorP    = [ effect parameterWithName:@"ZenithColor" ];

    AColorP = [ effect parameterWithName:@"AColor" ];
    BColorP = [ effect parameterWithName:@"BColor" ];
    CColorP = [ effect parameterWithName:@"CColor" ];
    DColorP = [ effect parameterWithName:@"DColor" ];
    EColorP = [ effect parameterWithName:@"EColor" ];

    sunElevationIncreaseAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"ElevationPlus" primaryInputAction:NP_INPUT_KEYBOARD_W ];
    sunElevationDecreaseAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"ElevationMinus" primaryInputAction:NP_INPUT_KEYBOARD_S ];

    return self;
}

- (void) dealloc
{
    modelMatrix = fm4_free(modelMatrix);
    position = fv3_free(position);
    sunTheta = fv2_free(sunTheta);
    lightDirection = fv3_free(lightDirection);
    zenithColor = fv3_free(zenithColor);

    [ super dealloc ];
}

- (FVector3 *) lightDirection
{
    return lightDirection;
}

- (void) update:(Float)frameTime
{
    *position = *[[[[ NP applicationController ] scene ] camera ] position ];
    position->y -= 10.0f;

    if ( [ sunElevationIncreaseAction active ] == YES )
    {
        lightDirection->y += 0.01f;

        if ( lightDirection->y > 0.99f )
        {
            lightDirection->y = 0.01f;
        }
    }

    if ( [ sunElevationDecreaseAction active ] == YES )
    {
        lightDirection->y -= 0.01f;

        if ( lightDirection->y < 0.01f )
        {
            lightDirection->y = 0.99f;
        }
    }

    fv3_v_normalise(lightDirection);

    sunTheta->x = acos(lightDirection->y);
	sunTheta->y = cos(sunTheta->x) * cos(sunTheta->x);

#define CBQ(X)		((X) * (X) * (X))
#define SQR(X)		((X) * (X))

    const double PI = (double)3.1415926535897932;

	zenithColor->x  = ( 0.00165f * CBQ(sunTheta->x) - 0.00374f  * SQR(sunTheta->x) +
  			            0.00208f * sunTheta->x + 0.0f) * SQR(turbidity) +
                      (-0.02902f * CBQ(sunTheta->x) + 0.06377f  * SQR(sunTheta->x) -
		       	        0.03202f * sunTheta->x  + 0.00394f) * turbidity +
		              ( 0.11693f * CBQ(sunTheta->x) - 0.21196f  * SQR(sunTheta->x) +
	       		        0.06052f * sunTheta->x + 0.25885f);

	zenithColor->y  = ( 0.00275f * CBQ(sunTheta->x) - 0.00610f  * SQR(sunTheta->x) +
			            0.00316f * sunTheta->x + 0.0f) * SQR(turbidity) +
                      (-0.04214f * CBQ(sunTheta->x) + 0.08970f  * SQR(sunTheta->x) -
		                0.04153f * sunTheta->x  + 0.00515f) * turbidity  +
		              ( 0.15346f * CBQ(sunTheta->x) - 0.26756f  * SQR(sunTheta->x) +
		                0.06669f * sunTheta->x  + 0.26688f);

	zenithColor->z  = (float)((4.0453f * turbidity - 4.9710f) *
			                  tan((4.0f / 9.0f - turbidity / 120.0f) *
                              (PI - 2.0f * sunTheta->x)) -
			                  0.2155f * turbidity + 2.4192f);

	// convert kcd/m² to cd/m²
	zenithColor->z *= 1000.0f;

}

- (void) render
{
    fm4_mv_translation_matrix(modelMatrix, position);
    [[[ NP Core ] transformationState ] setModelMatrix:modelMatrix ];

    NPEffect * effect = [[[ model materials ] objectAtIndex:0 ] effect ];

	double ABCDE_x[5], ABCDE_y[5], ABCDE_Y[5];

	ABCDE_x[0] = -0.01925 * turbidity - 0.25922;
	ABCDE_x[1] = -0.06651 * turbidity + 0.00081;
	ABCDE_x[2] = -0.00041 * turbidity + 0.21247;
	ABCDE_x[3] = -0.06409 * turbidity - 0.89887;
	ABCDE_x[4] = -0.00325 * turbidity + 0.04517;

	ABCDE_y[0] = -0.01669 * turbidity - 0.26078;
	ABCDE_y[1] = -0.09495 * turbidity + 0.00921;
	ABCDE_y[2] = -0.00792 * turbidity + 0.21023;
	ABCDE_y[3] = -0.04405 * turbidity - 1.65369;
	ABCDE_y[4] = -0.01092 * turbidity + 0.05291;

	ABCDE_Y[0] =  0.17872 * turbidity - 1.46303;
	ABCDE_Y[1] = -0.35540 * turbidity + 0.42749;
	ABCDE_Y[2] = -0.02266 * turbidity + 5.32505;
	ABCDE_Y[3] =  0.12064 * turbidity - 2.57705;
	ABCDE_Y[4] = -0.06696 * turbidity + 0.37027;

    FVector3 tmp;

    tmp.x = ABCDE_x[0]; tmp.y = ABCDE_y[0]; tmp.z = ABCDE_Y[0];
    [ effect uploadFVector3Parameter:AColorP andValue:&tmp ];

    tmp.x = ABCDE_x[1]; tmp.y = ABCDE_y[1]; tmp.z = ABCDE_Y[1];
    [ effect uploadFVector3Parameter:BColorP andValue:&tmp ];

    tmp.x = ABCDE_x[2]; tmp.y = ABCDE_y[2]; tmp.z = ABCDE_Y[2];
    [ effect uploadFVector3Parameter:CColorP andValue:&tmp ];

    tmp.x = ABCDE_x[3]; tmp.y = ABCDE_y[3]; tmp.z = ABCDE_Y[3];
    [ effect uploadFVector3Parameter:DColorP andValue:&tmp ];

    tmp.x = ABCDE_x[4]; tmp.y = ABCDE_y[4]; tmp.z = ABCDE_Y[4];
    [ effect uploadFVector3Parameter:EColorP andValue:&tmp ];

    [ effect uploadFVector3Parameter:lightDirectionP andValue:lightDirection ];
    [ effect uploadFVector2Parameter:thetaSunP andValue:sunTheta ];
    [ effect uploadFVector3Parameter:zenithColorP andValue:zenithColor ];

    [ stateset activate ];
    [ model render ];
}

@end
