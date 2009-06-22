#import "NP.h"
#import "RTVCore.h"
#import "RTVSliderItem.h"

@implementation RTVSliderItem

- (id) init
{
    return [ self initWithName:@"RTVSliderItem" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    position = fv2_alloc_init();
    size = fv2_alloc_init();
    sliderPosition = fv2_alloc_init();
    lineSize = fv2_alloc_init();
    headSize = fv2_alloc_init();

    return self;
}

- (void) dealloc
{
    fv2_free(position);
    fv2_free(size);
    fv2_free(sliderPosition);
    fv2_free(lineSize);
    fv2_free(headSize);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    NSArray * positionStrings = [ dictionary objectForKey:@"Position" ];
    position->x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position->y = [[ positionStrings objectAtIndex:1 ] floatValue ];

    NSArray * lineSizeStrings = [ dictionary objectForKey:@"LineSize" ];
    lineSize->x = [[ lineSizeStrings objectAtIndex:0 ] floatValue ];
    lineSize->y = [[ lineSizeStrings objectAtIndex:1 ] floatValue ];

    NSArray * headSizeStrings = [ dictionary objectForKey:@"HeadSize" ];
    headSize->x = [[ headSizeStrings objectAtIndex:0 ] floatValue ];
    headSize->y = [[ headSizeStrings objectAtIndex:1 ] floatValue ];

    NSArray * startPositionStrings = [ dictionary objectForKey:@"StartPosition" ];
    sliderPosition->x = [[ startPositionStrings objectAtIndex:0 ] floatValue ];
    sliderPosition->y = [[ startPositionStrings objectAtIndex:1 ] floatValue ];

    NSString * sliderLineTextureString = [ dictionary objectForKey:@"SliderLine" ];
    lineTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:sliderLineTextureString ];

    NSString * sliderHeadTextureString = [ dictionary objectForKey:@"SliderHead" ];
    headTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:sliderHeadTextureString ];

    NSString * effectString = [ dictionary objectForKey:@"Effect" ];
    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:effectString ];    

    return YES;
}

- (FVector2) position
{
    return *position;
}

- (FVector2) size
{
    return *size;
}

- (Float) scaleFactor
{
    return scaleFactor;
}

- (void) setPosition:(FVector2)newPosition
{
    *position = newPosition;
}

- (void) setSize:(FVector2)newSize
{
    *size = newSize;
}

- (BOOL) mouseHit:(FVector2)mousePosition
{
    BOOL result = NO;

    if ( mousePosition.x > position->x && mousePosition.x < position->x + size->x &&
         mousePosition.y < position->y && mousePosition.y > position->y - size->y )
    {
        result = YES;
    }

    return result;
}

- (void) onClick:(FVector2)mousePosition
{

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

    glBegin(GL_QUADS);

        glTexCoord2f(0.0f, 1.0f);
        glVertex4f(position->x, position->y, 0.0f, 1.0f);

        glTexCoord2f(0.0f, 0.0f);
        glVertex4f(position->x, position->y - lineSize->y, 0.0f, 1.0f);

        glTexCoord2f(1.0f, 0.0f);
        glVertex4f(position->x + lineSize->x, position->y - lineSize->y, 0.0f, 1.0f);

        glTexCoord2f(1.0f, 1.0f);
        glVertex4f(position->x + lineSize->x, position->y, 0.0f, 1.0f);

    glEnd();

    [ effect deactivate ];
}

@end

