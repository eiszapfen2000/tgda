#import "Core/NPObject/NPObject.h"

@class NPFile;

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

- (BOOL) allowDuplicates;
- (BOOL) allowEmptyStrings;
- (NSUInteger) count;
- (NSString *) stringAtIndex:(NSUInteger)index;

- (void) setAllowDuplicates:(BOOL)newAllowDuplicates;
- (void) setAllowEmptyStrings:(BOOL)newAllowEmptyStrings;

- (void) clear;
- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) loadFromPath:(NSString *)path;

- (void) addString:(NSString *)string;
- (void) addStringsFromArray:(NSArray *)array;

@end
