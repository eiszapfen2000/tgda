#import <Foundation/NSCharacterSet.h>
#import "Core/NPObject/NPObject.h"
#import "NPStringList.h"

@class NSCharacterSet;

@interface NPParser : NPObject
{
    NSCharacterSet * separators;
    NSCharacterSet * separatorsToStoreAsLiterals;
    NSCharacterSet * longLiteralMarkers;
    NSCharacterSet * ignoreMarkers;
    NSMutableArray * lines;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSUInteger) lineCount;
- (NSUInteger) tokenCountForLine:(NSUInteger)lineIndex;

- (void) setSeparators:(NSCharacterSet *)newSeparators;
- (void) setSeparatorsToStoreAsLiterals:(NSCharacterSet *)newSeparatorsToStoreAsLiterals;
- (void) setLongLiteralMarkers:(NSCharacterSet *)newLongLiteralMarkers;
- (void) setIgnoreMarkers:(NSCharacterSet *)newIgnoreMarkers;

- (NPStringList *) getTokensForLine:(NSUInteger)lineIndex;

- (NSString *) getTokenFromLine:(NSUInteger)lineIndex
                     atPosition:(NSUInteger)tokenIndex
                               ;

- (BOOL) getTokenAsString:(NSString **)string
                 fromLine:(NSUInteger)lineIndex
               atPosition:(NSUInteger)tokenIndex
                         ;

- (BOOL) getTokenAsLowerCaseString:(NSString **)string
                          fromLine:(NSUInteger)lineIndex
                        atPosition:(NSUInteger)tokenIndex
                                  ;

- (BOOL) getTokenAsInt:(int *)intValue
              fromLine:(NSUInteger)lineIndex
            atPosition:(NSUInteger)tokenIndex
                      ;

- (BOOL) getTokenAsFloat:(float *)floatValue
                fromLine:(NSUInteger)lineIndex
              atPosition:(NSUInteger)tokenIndex
                        ;

- (BOOL) getTokenAsDouble:(double *)doubleValue
                 fromLine:(NSUInteger)lineIndex
               atPosition:(NSUInteger)tokenIndex
                         ;

- (BOOL) getTokenAsBool:(BOOL *)boolValue
               fromLine:(NSUInteger)lineIndex
             atPosition:(NSUInteger)tokenIndex
                       ;

- (BOOL) isTokenFromLine:(NSUInteger)lineIndex
              atPosition:(NSUInteger)tokenIndex
           equalToString:(NSString *)string
                        ;

- (BOOL) isLowerCaseTokenFromLine:(NSUInteger)lineIndex
                       atPosition:(NSUInteger)tokenIndex
                    equalToString:(NSString *)string
                                 ;


- (void) parse:(NPStringList *)inputScript;

- (void) clear;

@end
