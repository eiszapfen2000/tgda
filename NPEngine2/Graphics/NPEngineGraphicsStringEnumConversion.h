#import "Core/NPObject/NPObject.h"
#import "NPEngineGraphicsEnums.h"

@class NSMutableDictionary;

@interface NPEngineGraphicsStringEnumConversion : NPObject
{
    // states
    NSMutableDictionary * blendingModes;
    NSMutableDictionary * comparisonFunctions;
    NSMutableDictionary * cullfaces;
    NSMutableDictionary * polygonFillModes;

    // effects
    NSMutableDictionary * effectVariableTypes;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
                   ;
- (void) dealloc;

- (void) startup;
- (void) shutdown;

- (NpBlendingMode) blendingModeForString:(NSString *)string;
- (NpComparisonFunction) comparisonFunctionForString:(NSString *)string;
- (NpCullface) cullfaceForString:(NSString *)string;
- (NpPolygonFillMode) polygonFillModeForString:(NSString *)string;

- (NpEffectVariableType) effectVariableTypeForString:(NSString *)string;

@end
