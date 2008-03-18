#import "Graphics/npgl.h"
#import "NPTextureManager.h"
#import "NPTexture.h"
#import "Core/File/NPFile.h"
#import "Core/File/NPPathManager.h"
#import "Core/NPEngineCore.h"

@implementation NPTextureManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPTextureManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    textures = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ textures release ];

    [ super dealloc ];
}

- (void) setup
{

}

- (id) loadTextureFromPath:(NSString *)path
{
    NSString * absolutePath = [ [ [ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadTextureFromAbsolutePath:absolutePath ];
}

- (id) loadTextureFromAbsolutePath:(NSString *)path
{
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        NPTexture * texture = [ textures objectForKey:path ];

        if ( texture == nil )
        {
            NPFile * file = [ [ NPFile alloc ] initWithName:path parent:self fileName:path ];
            texture = [ self loadTextureUsingFileHandle:file ];
            [ file release ];
        }

        return texture;
    }

    return nil;    
}

- (id) loadTextureUsingFileHandle:(NPFile *)file
{
    NPTexture * texture = [ [ NPTexture alloc ] initWithName:@"" parent:self ];

    if ( [ texture loadFromFile:file ] == YES )
    {
        [ textures setObject:texture forKey:[file fileName] ];
        [ texture release ];

        return texture;
    }
    else
    {
        [ texture release ];

        return nil;
    }    
}

@end
