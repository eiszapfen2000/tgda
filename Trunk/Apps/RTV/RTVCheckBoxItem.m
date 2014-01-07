#import "NP.h"
#import "RTVCore.h"
#import "RTVCheckBoxItem.h"

@implementation RTVCheckBoxItem

- (id) init
{
    return [ self initWithName:@"RTVCheckBoxItem" ];
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

    checked = NO;

    return self;
}

- (void) dealloc
{
    fv2_free(position);
    fv2_free(size);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    NSArray * positionStrings = [ dictionary objectForKey:@"Position" ];
    position->x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position->y = [[ positionStrings objectAtIndex:1 ] floatValue ];

    NSArray * sizeStrings = [ dictionary objectForKey:@"Size" ];
    size->x = [[ sizeStrings objectAtIndex:0 ] floatValue ];
    size->y = [[ sizeStrings objectAtIndex:1 ] floatValue ];

    NSString * checkedTextureString = [ dictionary objectForKey:@"CheckedTexture" ];
    NSString * uncheckedTextureString = [ dictionary objectForKey:@"UncheckedTexture" ];

    checkedTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:checkedTextureString ];
    uncheckedTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:uncheckedTextureString ];

    NSString * effectString = [ dictionary objectForKey:@"Effect" ];
    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:effectString ];    

    NSString * checkedString = [ dictionary objectForKey:@"Checked" ];
    checked = [ checkedString boolValue ];

    return YES;
}

- (BOOL) checked
{
    return checked;
}

- (FVector2) position
{
    return *position;
}

- (FVector2) size
{
    return *size;
}

- (NSString *) text
{
    return text;
}

- (void) setChecked:(BOOL)newChecked
{
    checked = newChecked;
}

- (void) setPosition:(FVector2)newPosition
{
    *position = newPosition;
}

- (void) setSize:(FVector2)newSize
{
    *size = newSize;
}

- (void) setText:(NSString *)newText
{
    ASSIGN(text, newText);
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
    if ( checked == NO )
    {

        checked = YES;
    }
    else
    {
        checked = NO;
    }
}

- (void) update:(Float)frameTime
{

}

- (void) render
{
    if ( effect == nil || checkedTexture == nil || uncheckedTexture == nil )
    {
        return;
    }

    id texture = nil;

    if ( checked == YES )
    {
        texture = checkedTexture;
    }
    else
    {
        texture = uncheckedTexture;
    }

    [ texture activateAtColorMapIndex:0 ];
    [ effect activate ];

    glBegin(GL_QUADS);

        glTexCoord2f(0.0f, 1.0f);
        glVertex4f(position->x, position->y, 0.0f, 1.0f);

        glTexCoord2f(0.0f, 0.0f);
        glVertex4f(position->x, position->y - size->y, 0.0f, 1.0f);

        glTexCoord2f(1.0f, 0.0f);
        glVertex4f(position->x + size->x, position->y - size->y, 0.0f, 1.0f);

        glTexCoord2f(1.0f, 1.0f);
        glVertex4f(position->x + size->x, position->y, 0.0f, 1.0f);

    glEnd();

    [ effect deactivate ];
}

@end

