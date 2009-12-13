#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>

#import "Core/Basics/NpTypes.h"
#import "NPPCoreProtocols.h"

@interface NPObject : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;
    NPObject * parent;
    NSValue * pointer;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (id <NPPObject>) parent;
- (void) setParent:(id <NPPObject>)newParent;

- (UInt32) objectID;

@end

//@interface NPObject ( NPCoding ) < NSCoding > @end

