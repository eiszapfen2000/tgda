#import "NPTextureBindingState.h"
#import "NPTexture.h"
#import "NPTexture3D.h"
#import "Graphics/npgl.h"
#import "Graphics/NPEngineGraphicsConstants.h"

@implementation NPTextureBindingState

- (id) init
{
    return [ self initWithName:@"NPEngine Core Texture Binding State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    textureBindings = [[ NSMutableDictionary alloc ] init ];
    textureUnits = [[ NSMutableArray alloc ] initWithCapacity:NP_GRAPHICS_SAMPLER_COUNT ];

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ textureUnits addObject:[NSNull null] ];
    }

    return self;
}

- (void) dealloc
{
    [ textureUnits removeAllObjects ];
    [ textureUnits release ];
    [ textureBindings removeAllObjects ];
    [ textureBindings release ];

    [ super dealloc ];
}

- (void) clear
{
    [ textureUnits removeAllObjects ];

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ textureUnits replaceObjectAtIndex:i withObject:[NSNull null] ];

        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, 0);       
    }
}

- (id) textureForKey:(NSString *)colormapSemantic
{
    return [ textureBindings objectForKey:colormapSemantic ];
}

- (void) setTexture:(id)texture forKey:(NSString *)colormapSemantic
{
    [ textureBindings setObject:texture forKey:colormapSemantic ]; 
}

@end
