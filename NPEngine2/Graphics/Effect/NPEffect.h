#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class NPStringList;
@class NSError;

@interface NPEffect : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;
    NSMutableArray * techniques;
    NSMutableArray * variables;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
                           ;

@end
