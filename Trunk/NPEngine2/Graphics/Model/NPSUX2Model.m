#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/File/NPFile.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "NPSUX2MaterialInstance.h"
#import "NPSUX2ModelLOD.h"
#import "NPSUX2Model.h"

@implementation NPSUX2Model

- (id) init
{
    return [ self initWithName:@"NPSUX2Model" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    lods = [[ NSMutableArray alloc ] init ];
    materials = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ materials removeAllObjects ];
    [ lods removeAllObjects ];

    DESTROY(materials);
    DESTROY(lods);

    SAFE_DESTROY(file);

    [ super dealloc ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (NPSUX2ModelLOD *) lodAtIndex:(const NSUInteger)index
{
    return [ lods objectAtIndex:index ];
}

- (NPSUX2MaterialInstance *) materialInstanceAtIndex:(const NSUInteger)index
{
    return [ materials objectAtIndex:index ];
}


- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    const char * suxHeader = "SUX____1";
    char headerFromFile[8];

    if ( [ stream readElementsToBuffer:headerFromFile
                           elementSize:sizeof(char)
                      numberOfElements:8 ] == NO )
    {
        NPLOG(@"Failed to read header");
        return NO;
    }

    if ( strncmp(suxHeader, headerFromFile, 8) != 0 )
    {
        NPLOG(@"Wrong header version");
        return NO;
    }

    NSString * modelName;
    NSAssert([ stream readSUXString:&modelName ] == YES, @"");
    [ self setName:modelName ];

    NPLOG(@"Model Name: %@", name);

    int32_t materialCount = 0;
    NSAssert([ stream readInt32:&materialCount ] == YES, @"");

    NPLOG(@"Material Count: %d", materialCount);

    for ( int32_t i = 0; i < materialCount; i++ )
    {
        NPSUX2MaterialInstance * mInstance
            = [[ NPSUX2MaterialInstance alloc ] init ];

        if ( [ mInstance loadFromStream:stream
                                  error:NULL ] == YES )
        {
            [ materials addObject:mInstance ];
        }

        DESTROY(mInstance);
    }

    int32_t lodCount = 0;
    [ stream readInt32:&lodCount ];
    NPLOG(@"LOD count: %d", lodCount);

    for ( int32_t i = 0; i < lodCount; i++ )
    {
        NPSUX2ModelLOD * lod
            = [[ NPSUX2ModelLOD alloc ] init ];
        [ lod setModel:self ];

        if ( [ lod loadFromStream:stream
                            error:NULL ] == YES )
        {
            [ lods addObject:lod ];
        }

        DESTROY(lod);
    }

    ready = ([ lods count ] != 0);

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"");
    NPLOG(@"Loading SUX2 model \"%@\"", completeFileName);

    NPFile * fileStream
        = [[ NPFile alloc ] initWithName:@"SUX2ModelFile"
                                fileName:completeFileName
                                    mode:NpStreamRead
                                   error:error ];

    if ( fileStream == nil )
    {
        return NO;
    }

    BOOL result = [ self loadFromStream:fileStream error:error ];
    DESTROY(fileStream);

    return result;
}

- (void) render
{
    [ self renderLOD:0 withMaterial:YES ];
}

- (void) renderLOD:(uint32_t)index
{
    [ self renderLOD:index withMaterial:YES ];
}

- (void) renderLOD:(uint32_t)index withMaterial:(BOOL)renderMaterial
{
    if ( ready == NO )
    {
        NPLOG(@"Model not ready");
        return;
    }

    [[ lods objectAtIndex:index ] renderWithMaterial:renderMaterial ];
}

@end
