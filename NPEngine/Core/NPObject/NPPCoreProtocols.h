#import <Foundation/Foundation.h>

@class NPObject;

@protocol NPPObject < NSObject >

- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (id <NPPObject>) parent;
- (void) setParent:(id <NPPObject> )newParent;

- (UInt32) objectID;

@end

