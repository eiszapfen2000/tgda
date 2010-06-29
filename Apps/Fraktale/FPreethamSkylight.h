#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class NPSUXModel;
@class NPStateSet;
@class NPInputAction;

@interface FPreethamSkylight : NPObject
{
    NPSUXModel * model;
    NPStateSet * stateset;

    FMatrix4 * scaleMatrix;
    FMatrix4 * translationMatrix;
    FVector3 * position;

    FVector2 * sunTheta;
    FVector3 * lightDirection;
    FVector3 * zenithColor;
    Float turbidity;

    CGparameter lightDirectionP;
    CGparameter thetaSunP;
    CGparameter zenithColorP;
    CGparameter AColorP;
    CGparameter BColorP;
    CGparameter CColorP;
    CGparameter DColorP;
    CGparameter EColorP;

    NPInputAction * sunElevationIncreaseAction;
    NPInputAction * sunElevationDecreaseAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (FVector3 *) lightDirection;

- (void) update:(Float)frameTime;
- (void) render;

@end
