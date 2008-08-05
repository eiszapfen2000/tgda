#import <Foundation/Foundation.h>

@class NPObject;

@protocol NPPObject

- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (NPObject *) parent;
- (void) setParent:(id <NPPObject> )newParent;

- (UInt32) objectID;

@end

