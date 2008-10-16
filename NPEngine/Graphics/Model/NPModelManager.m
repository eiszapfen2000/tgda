#import "NPModelManager.h"
#import "NPSUXModel.h"
#import "Core/File/NPFile.h"
#import "Core/File/NPPathManager.h"
#import "Core/File/NPPathUtilities.h"
#import "Core/NPEngineCore.h"

@implementation NPModelManager

- (id) init
{
    return [ self initWithName:@"NPEngine Pathmanager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    models = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ models removeAllObjects ];
    [ models release ];

    [ super dealloc ];
}

- (id) loadModelFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadModelFromAbsolutePath:absolutePath ];
}

- (id) loadModelFromAbsolutePath:(NSString *)path
{
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        NPSUXModel * model = [ models objectForKey:path ];

        if ( model == nil )
        {
            NPFile * file = [[ NPFile alloc ] initWithName:path parent:self fileName:path ];
            model = [ self loadModelUsingFileHandle:file ];
            [ file release ];
        }

        return model;
    }

    return nil;
}

- (id) loadModelUsingFileHandle:(NPFile *)file
{
    NPSUXModel * model = [[ NPSUXModel alloc ] initWithName:@"" parent:self ];

    if ( [ model loadFromFile:file ] == YES )
    {
        [ models setObject:model forKey:[file fileName] ];
        [ model release ];

        return model;
    }
    else
    {
        [ model release ];

        return nil;
    } 
}

- (BOOL) saveModel:(NPSUXModel *)model atAbsolutePath:(NSString *)path
{
    NpState mode = NP_FILE_WRITING;

    if ( isDirectory(path) == YES )
    {
        NPLOG_WARNING(([NSString stringWithFormat:@"%@ is a directory", path]));
        return NO;
    }

    if ( isFile(path) == YES )
    {
        NPLOG(([NSString stringWithFormat:@"%@ already exist, overwriting...", path]));
        mode = NP_FILE_UPDATING;        
    }
    else
    {
        if ( createEmptyFile(path) == NO )
        {
            NPLOG_WARNING(([NSString stringWithFormat:@"Could not create file %@", path]));
            return NO;
        }
    }

    NPFile * file = [[ NPFile alloc ] initWithName:@"" parent:self fileName:path mode:mode ];

    if ( [ model saveToFile:file ] == NO )
    {
        [ file release ];
        return NO;
    }

    [ file release ];

    return YES;
}

@end
