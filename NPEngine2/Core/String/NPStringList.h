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

- (NPStringList *) stringsWithPrefix:(NSString *)prefix;
- (NPStringList *) stringsWithSuffix:(NSString *)suffix;
- (NPStringList *) stringsWithPrefix:(NSString *)prefix
                             indexes:(NSIndexSet **)indexes
                                    ;
- (NPStringList *) stringsWithSuffix:(NSString *)suffix
                             indexes:(NSIndexSet **)indexes
                                    ;

- (NSUInteger) indexOfFirstStringWithPrefix:(NSString *)prefix;
- (NSUInteger) indexOfFirstStringWithSuffix:(NSString *)suffix;
- (NSUInteger) indexOfLastStringWithPrefix:(NSString *)prefix;
- (NSUInteger) indexOfLastStringWithSuffix:(NSString *)suffix;

- (void) replaceStringAtIndex:(NSUInteger)index
                   withString:(NSString *)string
                             ;

- (void) replaceStringsAtIndexes:(NSIndexSet *)indexes
                     withStrings:(NSArray *)array
                                ;

- (void) replaceStringsAtIndexes:(NSIndexSet *)indexes
                  withStringList:(NPStringList *)stringList
                                ;

@end

