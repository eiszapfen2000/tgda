#import "NP.h"
#import "ODMenu.h"
#import "ODSliderItem.h"

@implementation ODSliderItem

- (id) init
{
    return [ self initWithName:@"ODSliderItem" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    lineGeometry = frectangle_alloc_init();
    headGeometry = frectangle_alloc_init();

    alignment = NP_NONE;

    return self;
}

- (void) dealloc
{
    frectangle_free(lineGeometry);
    frectangle_free(headGeometry);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    NSArray * positionStrings = [ dictionary objectForKey:@"Position" ];
    NSArray * lineSizeStrings = [ dictionary objectForKey:@"LineSize" ];
    NSArray * headSizeStrings = [ dictionary objectForKey:@"HeadSize" ];

    NSString * alignmentString     = [ dictionary objectForKey:@"Alignment" ];
    NSString * startPositionString = [ dictionary objectForKey:@"StartPosition" ];

    if ( positionStrings == nil || lineSizeStrings == nil || headSizeStrings == nil ||
         alignmentString == nil || startPositionString == nil )
    {
        NPLOG_ERROR(@"Dictionary incomplete");
        return NO;
    }

    FVector2 position, lineSize, headSize;

    position.x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] floatValue ];
    lineSize.x = [[ lineSizeStrings objectAtIndex:0 ] floatValue ];
    lineSize.y = [[ lineSizeStrings objectAtIndex:1 ] floatValue ];
    headSize.x = [[ headSizeStrings objectAtIndex:0 ] floatValue ];
    headSize.y = [[ headSizeStrings objectAtIndex:1 ] floatValue ];

    alignment  = [[ (ODMenu *)parent valueForKeyword:alignmentString ] intValue ];

    frectangle_vv_init_with_min_and_size_r(&position, &lineSize, lineGeometry);
    [ ODMenu alignRectangle:lineGeometry withAlignment:alignment ];

    Float halfHeadWidth = headSize.x * 0.5f;
    FVector2 sliderPosition = lineGeometry->min;
    sliderPosition.x -= halfHeadWidth;

    if ( [ startPositionString isEqual:@"Center" ] == YES )
    {
        sliderPosition.x += lineSize.x * 0.5f;
    }

    if ( [ startPositionString isEqual:@"Right" ] == YES )
    {
        sliderPosition.x += lineSize.x;
    }

    frectangle_vv_init_with_min_and_size_r(&sliderPosition, &headSize, headGeometry);

    lineTexture = [ (ODMenu *)parent textureForKey:@"SliderLine" ];
    headTexture = [ (ODMenu *)parent textureForKey:@"SliderHead" ];
    effect      = [ (ODMenu *)parent menuEffect ];

    NSString * targetObjectString   = [ dictionary objectForKey:@"TargetObject" ];
    target = [[[ NP Core ] objectManager ] objectByName:targetObjectString ];
    NSAssert1(target != nil, @"%@ not found", targetObjectString);

    NSString * targetPropertyString = [ dictionary objectForKey:@"TargetProperty" ];
    BOOL propertyFound = GSObjCFindVariable(target, [ targetPropertyString cStringUsingEncoding:NSASCIIStringEncoding ], NULL, &size, &offset );
    NSAssert1(propertyFound != NO, @"Property with Name \"%@\" not found", targetPropertyString);

    return YES;
}

- (Float) scaleFactor
{
    Float headCenter = frectangle_r_calculate_x_center(headGeometry);
    Float lineWidth  = frectangle_r_calculate_width(lineGeometry);

    return (headCenter - lineGeometry->min.x) / lineWidth;
}

- (BOOL) mouseHit:(FVector2)mousePosition
{
    BOOL result = NO;

    if ( frectangle_vr_is_point_inside(&mousePosition, lineGeometry) == 1 )
    {
        result = YES;
    }

    return result;
}

- (void) onClick:(FVector2)mousePosition
{
    Float width = frectangle_r_calculate_width(headGeometry);

    headGeometry->min.x = mousePosition.x - width * 0.5f;
    headGeometry->max.x = mousePosition.x + width * 0.5f;

    Float brak = [ self scaleFactor ];

    GSObjCSetVariable(target, offset, size, &brak);
}

- (void) update:(Float)frameTime
{

}

- (void) render
{
    if ( effect == nil || lineTexture == nil || headTexture == nil )
    {
        return;
    }

    [ lineTexture activateAtColorMapIndex:0 ];
    [ effect activate ];

    [ NPPrimitivesRendering renderFRectangle:lineGeometry ];

    [ headTexture activateAtColorMapIndex:0 ];
    [ effect activate ];

    [ NPPrimitivesRendering renderFRectangle:headGeometry ];

    [ effect deactivate ];
}

@end

