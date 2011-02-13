#import "Core/NPObject/NPObject.h"
#import "NPEngineGraphicsEnums.h"

@class NSMutableDictionary;

@interface NPEngineGraphicsStringEnumConversion : NPObject
{
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

- (NpEffectVariableType) effectVariableTypeForString:(NSString *)string;

@end
