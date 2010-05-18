#import <Foundation/NSArray.h>
#import "Core/NPObject/NPObject.h"

@interface NPStringList : NPObject
{
    NSMutableArray * lines;

    BOOL allowDuplicates;
    BOOL allowEmptyStrings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
    allowDuplicates:(BOOL)newAllowDuplicates
  allowEmptyStrings:(BOOL)newAllowEmptyStrings
                   ;
- (void) dealloc;

- (void) clear;
- (void) addString:(NSString *)string;

- (BOOL) loadFromPath:(NSString *)path;

@end
