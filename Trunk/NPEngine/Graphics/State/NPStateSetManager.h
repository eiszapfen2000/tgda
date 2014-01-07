#import "Core/NPObject/NPObject.h"

@interface NPStateSetManager : NPObject
{
    NSMutableDictionary * keywordMappings;
    NSMutableDictionary * stateSets;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSDictionary *) keywordMappings;
- (id) valueForKeyword:(NSString *)keyword;

- (id) loadStateSetFromPath:(NSString *)path;
- (id) loadStateSetFromAbsolutePath:(NSString *)path;

@end
