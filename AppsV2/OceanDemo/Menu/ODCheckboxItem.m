#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPEngineCore.h"
#import "ODCheckboxItem.h"

@implementation ODCheckboxItem

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
               menu:(ODMenu *)newMenu
{
    self = [ super initWithName:newName menu:newMenu ];

    checked = NO;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
{
    BOOL result
        = [ super loadFromDictionary:source error:error ];

    if ( result == NO )
    {
        return NO;
    }

    NSString * targetObjectString   = [ source objectForKey:@"TargetObject"   ];
    NSString * targetPropertyString = [ source objectForKey:@"TargetProperty" ];

    if ( targetObjectString != nil )
    {
        target
            = [[[ NPEngineCore instance ]
                     objectManager ] objectByName:targetObjectString ];

        NSAssert1(target != nil, @"Object with name \"%@\" not found",
                  targetObjectString);

        if ( targetPropertyString != nil )
        {
            BOOL propertyFound
                = GSObjCFindVariable(target,
                    [ targetPropertyString cStringUsingEncoding:NSASCIIStringEncoding ],
                    NULL, &size, &offset );

            NSAssert1(propertyFound != NO, @"Property with name \"%@\" not found",
                      targetPropertyString);

            GSObjCGetVariable(target, offset, size, &checked);
        }
    }

    return result;
}

@end
