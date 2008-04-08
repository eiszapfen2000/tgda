#import "NPImageManager.h"
#import "NPImage.h"
#import "Core/File/NPFile.h"
#import "Core/File/NPPathManager.h"
#import "Core/NPEngineCore.h"

#import "IL/il.h"
#import "IL/ilu.h"

@implementation NPImageManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPImageManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    images = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ images release ];

    [ super dealloc ];
}

- (void) setup
{
    NPLOG(@"NPImageManager setup...");
    NPLOG(@"Initialising DevIL...");

    Int devilVersion = ilGetInteger(IL_VERSION_NUM);
    NPLOG(([NSString stringWithFormat:@"DevIL version is %d",devilVersion ]));

    if ( devilVersion < IL_VERSION)
    {
        NPLOG_WARNING(([NSString stringWithFormat:@"DevIL library version %d does not match DevIL header version %d",devilVersion,IL_VERSION]));
    }

    ilInit();
    iluInit();

    NPLOG(@"NPImageManager ready");
}

- (id) loadImageFromPath:(NSString *)path
{
    NSString * absolutePath = [ [ [ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadImageFromAbsolutePath:absolutePath ];

}

- (id) loadImageFromAbsolutePath:(NSString *)path;
{
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        NPImage * image = [ images objectForKey:path ];

        if ( image == nil )
        {
            NPFile * file = [ [ NPFile alloc ] initWithName:path parent:self fileName:path ];
            image = [ self loadImageUsingFileHandle:file ];
            [ file release ];
        }

        return image;
    }

    return nil;    
}

- (id) loadImageUsingFileHandle:(NPFile *)file
{
    NPImage * image = [ [ NPImage alloc ] initWithName:@"" parent:self ];

    if ( [ image loadFromFile:file ] == YES )
    {
        [ images setObject:image forKey:[file fileName] ];
        [ image release ];

        return image;
    }
    else
    {
        [ image release ];

        return nil;
    }    
}

@end
