#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@class NPObject;

@protocol NPPObject < NSObject >

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;

- (NSString *) name;
- (id <NPPObject>) parent;
- (UInt32) objectID;

- (void) setName:(NSString *)newName;
- (void) setParent:(id <NPPObject> )newParent;

@end

