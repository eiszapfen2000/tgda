#import "NP.h"
#import "ODMenu.h"
#import "ODCheckBoxItem.h"

@implementation ODCheckBoxItem

- (id) init
{
    return [ self initWithName:@"ODCheckBoxItem" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    geometry = frectangle_alloc_init();
    alignment = NP_NONE;
    checked = NO;

    return self;
}

- (void) dealloc
{
    frectangle_free(geometry);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    description = [[ dictionary objectForKey:@"Description" ] retain ];

    NSArray * positionStrings = [ dictionary objectForKey:@"Position" ];
    NSArray * sizeStrings     = [ dictionary objectForKey:@"Size" ];

    NSString * alignmentString = [ dictionary objectForKey:@"Alignment" ];
    NSString * checkedString   = [ dictionary objectForKey:@"Checked" ];

    NSString * targetObjectString   = [ dictionary objectForKey:@"TargetObject" ];
    NSString * targetPropertyString = [ dictionary objectForKey:@"TargetProperty" ];

    if ( positionStrings == nil || sizeStrings == nil || alignmentString == nil ||
         checkedString == nil || description == nil )
    {
        NPLOG_ERROR(@"Dictionary incomplete");
        return NO;
    }

    FVector2 position, checkBoxSize;

    position.x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] floatValue ];

    checkBoxSize.x = [[ sizeStrings objectAtIndex:0 ] floatValue ];
    checkBoxSize.y = [[ sizeStrings objectAtIndex:1 ] floatValue ];

    alignment = [[ (ODMenu *)parent valueForKeyword:alignmentString ] intValue ];
    checked = [ checkedString boolValue ];

    frectangle_vv_init_with_min_and_size_r(&position, &checkBoxSize, geometry);
    [ ODMenu alignRectangle:geometry withAlignment:alignment ];

    if ( targetObjectString != nil )
    {
        target = [[[ NP Core ] objectManager ] objectByName:targetObjectString ];
        NSAssert1(target != nil, @"Object with name \"%@\" not found", targetObjectString);

        if ( targetPropertyString != nil )
        {
            BOOL propertyFound = GSObjCFindVariable(target, [ targetPropertyString cStringUsingEncoding:NSASCIIStringEncoding ], NULL, &size, &offset );
            NSAssert1(propertyFound != NO, @"Property with name \"%@\" not found", targetPropertyString);
        }
    }

    checkedTexture   = [ (ODMenu *)parent textureForKey:@"Checked" ];
    uncheckedTexture = [ (ODMenu *)parent textureForKey:@"Unchecked" ];
    effect = [ (ODMenu *)parent effect ];

    return YES;
}

- (BOOL) checked
{
    return checked;
}

- (void) setChecked:(BOOL)newChecked
{
    checked = newChecked;
}

- (BOOL) mouseHit:(FVector2)mousePosition
{
    BOOL result = NO;

    if ( frectangle_vr_is_point_inside(&mousePosition, geometry) == 1 )
    {
        result = YES;
    }

    return result;
}

- (void) onClick:(FVector2)mousePosition
{
    if ( checked == NO )
    {
        checked = YES;
    }
    else
    {
        checked = NO;
    }

    if ( target != nil && size > 0 )
    {
        GSObjCSetVariable(target, offset, size, &checked);
    }
}

- (void) render
{
    if ( effect == nil || checkedTexture == nil || uncheckedTexture == nil )
    {
        return;
    }

    NPTexture * texture = nil;

    if ( checked == YES )
    {
        texture = checkedTexture;
    }
    else
    {
        texture = uncheckedTexture;
    }

    FVector2 position = { geometry->min.x, geometry->max.y + 0.035f };
    [[ (ODMenu *)parent font ] renderString:description atPosition:&position withSize:0.035f ];

    [ texture activateAtColorMapIndex:0 ];
    [ effect activate ];
    [ NPPrimitivesRendering renderFRectangle:geometry ];
    [ effect deactivate ];
}

@end

