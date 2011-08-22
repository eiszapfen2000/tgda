#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODEntity.h"

@class NPSUX2Model;
@class NPStateSet;
@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat3;

@interface ODPreethamSkylight : ODEntity
{
    FVector2 sunTheta;
    FVector3 lightDirection;
    FVector3 zenithColor;
    float turbidity;

    NPEffectVariableFloat3 * A_Yxy_P;
    NPEffectVariableFloat3 * B_Yxy_P;
    NPEffectVariableFloat3 * C_Yxy_P;
    NPEffectVariableFloat3 * D_Yxy_P;
    NPEffectVariableFloat3 * E_Yxy_P;
    NPEffectVariableFloat3 * zenithColor_P;

    /*
    CGparameter lightDirectionP;
    CGparameter thetaSunP;
    */
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

