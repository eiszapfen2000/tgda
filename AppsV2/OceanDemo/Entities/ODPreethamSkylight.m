#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/State/NPStateSet.h"
#import "ODPreethamSkylight.h"


@implementation ODPreethamSkylight

- (id) init
{
    return [ self initWithName:@"ODPreethamSkylight" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    fv2_v_init_with_zeros(&sunTheta);
    fv3_v_init_with_zeros(&lightDirection);
    fv3_v_init_with_zeros(&zenithColor);

    // turbidity must be in the range 2 - 6
    turbidity = 3.0f;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    /*
    NSString * entityName      = [ config objectForKey:@"Name"     ];
    NSString * modelPath       = [ config objectForKey:@"Model"    ];
    NSString * statesetPath    = [ config objectForKey:@"States"   ];

    if ( modelPath == nil || statesetPath == nil || entityName == nil )
    {
        NPLOG_ERROR(@"%@: Dictionary incomplete.", name);
        return NO;
    }

    [ self setName:entityName ];

    model    = [[[ NP Graphics ] modelManager    ] loadModelFromPath:modelPath       ];
    stateset = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:statesetPath ];

    if ( model == nil || stateset == nil )
    {
        return NO;
    }

    NPEffect * effect = [[[ model materials ] objectAtIndex:0 ] effect ];

    lightDirectionP = [ effect parameterWithName:@"LightDirection" ];
    thetaSunP       = [ effect parameterWithName:@"ThetaSun" ];
    zenithColorP    = [ effect parameterWithName:@"ZenithColor" ];

    AColorP = [ effect parameterWithName:@"AColor" ];
    BColorP = [ effect parameterWithName:@"BColor" ];
    CColorP = [ effect parameterWithName:@"CColor" ];
    DColorP = [ effect parameterWithName:@"DColor" ];
    EColorP = [ effect parameterWithName:@"EColor" ];
    */

    return NO;
}

- (void) update:(const float)frameTime
{
}

- (void) render
{
}

/*
- (void) update:(const float)frameTime
{
    *position = *[[[[[ NP applicationController ] sceneManager ] currentScene ] camera ] position ];

    lightDirection->x = -1.0f;
    lightDirection->y = 0.5f;
    lightDirection->z = -1.0f;
    fv3_v_normalise(lightDirection);

    turbidity = 3.0f;

    sunTheta->x = acos( lightDirection->y );
	sunTheta->y = cos( sunTheta->x ) * cos( sunTheta->x );

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
*/

/*
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
*/

@end
