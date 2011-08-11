#import "ODMenuItem.h"

@interface ODCheckboxItem : ODMenuItem
{
    BOOL checked;

    id target;
    uint32_t size;
    int32_t offset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
               menu:(ODMenu *)newMenu
                   ;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
                           ;

@end
