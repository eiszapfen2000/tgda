#import "NPTextureManager.h"
#import "NPTexture.h"
#import "Core/File/NPFile.h"
#import "Core/File/NPPathManager.h"
#import "Core/NPEngineCore.h"

#import "IL/il.h"
#import "IL/ilu.h"
#import "IL/ilut.h"

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
    NPLOG(@"NPTextureManager setup...");

    ilInit();
    iluInit();
    ilutInit();

    NPLOG(@"...done");
}

- (id) loadTextureFromPath:(NSString *)path
{
    NSString * absolutePath = [ [ [ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, absolutePath]));

    if ( [ absolutePath isEqual:path ] == NO )
    {
        NPTexture * texture = [ textures objectForKey:absolutePath ];

        if ( texture == nil )
        {
            NPFile * file = [ [ NPFile alloc ] initWithName:path parent:self fileName:absolutePath ];
            texture = [ [ NPTexture alloc ] initWithName:@"" parent:self ];

            if ( [ texture loadFromFile:file ] == YES )
            {
                [ textures setObject:texture forKey:absolutePath ];
                [ texture release ];
                [ file release ];

                return texture;
            }
            else
            {
                [ texture release ];
                [ file release ];

                return nil;
            }
        }
        else
        {
            return texture;
        }
    }

    return nil;
}

@end
