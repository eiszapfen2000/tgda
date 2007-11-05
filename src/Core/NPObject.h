#import <Foundation/Foundation.h>

@interface NPObject : NSObject
{
    NSString * name;
}

- (id) init;
- (id) initWithName: (NSString *) newName;
- (void) dealloc;

- (void) setup;

- (NSString *) name;
- (void) setName: (NSString *) newName;

@end
