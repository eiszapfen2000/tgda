#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODEntity.h"

@class NPSUX2Model;
@class NPStateSet;

@interface ODPreethamSkylight : ODEntity
{
    FVector2 sunTheta;
    FVector3 lightDirection;
    FVector3 zenithColor;
    float turbidity;

    /*
    CGparameter lightDirectionP;
    CGparameter thetaSunP;
    CGparameter zenithColorP;
    CGparameter AColorP;
    CGparameter BColorP;
    CGparameter CColorP;
    CGparameter DColorP;
    CGparameter EColorP;
    */
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

