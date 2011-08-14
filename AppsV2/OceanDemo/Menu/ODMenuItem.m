#import <objc/runtime.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "Graphics/NSString+NPEngineGraphicsEnums.h"
#import "ODMenu.h"
#import "ODMenuItem.h"

BOOL ODObjCFindVariable(id obj, const char * name,
    NSUInteger * size, ptrdiff_t * offset)
{
    Class class = object_getClass(obj);
    Ivar  ivar  = class_getInstanceVariable(class, name);

    if ( ivar == NULL )
    {
        return NO;
    }
    else
    {
        const char * encoding = ivar_getTypeEncoding(ivar);

        if ( size != NULL )
        {
            NSUInteger tSize;
            NSGetSizeAndAlignment(encoding, &tSize, NULL);
            *size = tSize;
        }

        if ( offset != NULL )
        {
            *offset = ivar_getOffset(ivar);
        }

        return YES;
    }
}

void ODObjCGetVariable(id obj, const ptrdiff_t offset,
    const NSUInteger size, void * data)
{
    memcpy(data, ((char *)obj) + offset, size);
}

void ODObjCSetVariable(id obj, const ptrdiff_t offset,
    const NSUInteger size, const void * data)
{
    memcpy(((char *)obj) + offset, data, size);
}

@implementation ODMenuItem

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
    self = [ super initWithName:newName ];

    NSAssert(newMenu != nil, @"");

    menu = newMenu;
    alignment = NpOrthographicAlignUnknown;
    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &geometry);
    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &alignedGeometry);
    textSize = 0;

    return self;
}

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    NSArray * positionStrings  = [ source objectForKey:@"Position"  ];
    NSArray * sizeStrings      = [ source objectForKey:@"Size"      ];
    NSString * alignmentString = [ source objectForKey:@"Alignment" ];
    NSString * textSizeString  = [ source objectForKey:@"TextSize"  ];

    NSAssert(positionStrings != nil && sizeStrings != nil
             && alignmentString != nil && textSizeString != nil, @"");

    // alignment
    alignment
        = [[ alignmentString lowercaseString ]
                orthographicAlignmentValueWithDefault:NpOrthographicAlignUnknown ];

    // text size
    textSize = (uint32_t)[ textSizeString intValue ];
    
    // position and size
    FVector2 position, checkBoxSize;
    position.x = [[ positionStrings objectAtIndex:0 ] intValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] intValue ];
    checkBoxSize.x = [[ sizeStrings objectAtIndex:0 ] intValue ];
    checkBoxSize.y = [[ sizeStrings objectAtIndex:1 ] intValue ];
    frectangle_vv_init_with_min_and_size_r(&position, &checkBoxSize, &geometry);

    // target property
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
                = ODObjCFindVariable(target,
                    [ targetPropertyString cStringUsingEncoding:NSASCIIStringEncoding ],
                    &size, &offset );

            NSAssert1(propertyFound != NO, @"Property with name \"%@\" not found",
                      targetPropertyString);
        }
    }

    return YES;
}

- (BOOL) isHit:(const FVector2)mousePosition
{
    return frectangle_vr_is_point_inside(&mousePosition, &alignedGeometry);
}

- (void) onClick:(const FVector2)mousePosition
{
    [ self subclassResponsibility:_cmd ];
}

- (void) update:(const float)frameTime
{
    [ self subclassResponsibility:_cmd ];
}

- (void) render
{
    [ self subclassResponsibility:_cmd ];
}

@end

