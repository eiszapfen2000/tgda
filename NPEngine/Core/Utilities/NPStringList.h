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
- (BOOL) loadFromPath:(NSString *)path;

- (NSUInteger) count;
- (void) addString:(NSString *)string;
- (void) addStringsFromArray:(NSArray *)array;
- (NSString *) stringAtIndex:(NSUInteger)index;


@end
