#import "NPTextureBindingState.h"

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

    return self;
}

- (void) dealloc
{
    [ textureBindings release ];

    [ super dealloc ];
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
