#import "ODMenuItem.h"

@interface ODButtonItem : ODMenuItem
{
    BOOL active;
    FRectangle pixelCenterGeometry;
    NSString * label;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
               menu:(ODMenu *)newMenu
                   ;

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
                           ;

@end
