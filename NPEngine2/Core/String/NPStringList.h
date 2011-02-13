#import <Foundation/NSArray.h>
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSError;

@interface NPStringList : NPObject < NPPPersistentObject >
{
    NSString * file;
    NSMutableArray * strings;

    BOOL allowDuplicates;
    BOOL allowEmptyStrings;
}

+ (id) stringList;
+ (id) stringListWithContentsOfFile:(NSString *)fileName
                              error:(NSError **)error
                                   ;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
                   ;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
    allowDuplicates:(BOOL)newAllowDuplicates
  allowEmptyStrings:(BOOL)newAllowEmptyStrings
                   ;
- (void) dealloc;

- (void) clear;

- (BOOL) allowDuplicates;
- (BOOL) allowEmptyStrings;
- (void) setAllowDuplicates:(BOOL)newAllowDuplicates;
- (void) setAllowEmptyStrings:(BOOL)newAllowEmptyStrings;

- (NSUInteger) count;

- (void) addString:(NSString *)string;
- (void) addStrings:(NSArray *)array;
- (void) addStringList:(NPStringList *)stringList;

- (void) insertString:(NSString *)string atIndex:(NSUInteger)index;
- (void) insertStrings:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void) insertStrings:(NSArray *)array atIndex:(NSUInteger)index;
- (void) insertStringList:(NPStringList *)stringList
                  atIndex:(NSUInteger)index
                         ;

- (NSString *) stringAtIndex:(NSUInteger)index;
- (NPStringList *) stringListInRange:(NSRange)range;

- (NSArray *) stringsWithPrefix:(NSString *)prefix;
- (NSArray *) stringsWithSuffix:(NSString *)suffix;

@end

