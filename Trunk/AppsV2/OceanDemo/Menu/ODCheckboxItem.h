#import "ODMenuItem.h"

@interface ODCheckboxItem : ODMenuItem
{
    BOOL checked;
    FRectangle pixelCenterGeometry;
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
