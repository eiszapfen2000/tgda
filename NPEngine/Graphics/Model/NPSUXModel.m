#import <string.h>

#import "NPSUXModel.h"
#import "NPSUXModelLod.h"
#import "Graphics/Material/NPSUXMaterialInstance.h"
#import "Graphics/Material/NPTexture.h"
#import "Core/NPEngineCore.h"

@implementation NPSUXModel

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NP SUX Model" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    lods = [ [ NSMutableArray alloc ] init ];
    materials = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    Char * suxHeader = "SUX____1";

    Char headerFromFile[8];
    [ file readChars:headerFromFile withLength:8 ];

    if ( strncmp(suxHeader,headerFromFile,8) != 0 )
    {
        NPLOG_ERROR(([NSString stringWithFormat:@"%@: wrong header version", [file fileName ]]));

        return NO;
    }

    NSString * modelName = [ file readSUXString ];
    [ self setName:modelName ];
    [ modelName release ];
    NPLOG(([NSString stringWithFormat:@"Model Name: %@", name]));

    Int materialCount = 0;
    [ file readInt32:&materialCount ];
    NPLOG(([NSString stringWithFormat:@"Material Count: %d", materialCount]));

    for ( Int i = 0; i < materialCount; i++ )
    {
        NPSUXMaterialInstance * materialInstance = [ [ NPSUXMaterialInstance alloc ] init ];

        if ( [ materialInstance loadFromFile:file ] == YES )
        {
            [ materials addObject:materialInstance ];
        }

        [ materialInstance release ];
    }

    Int lodCount = 0;
    [ file readInt32:&lodCount ];
    NPLOG(([NSString stringWithFormat:@"LOD count: %d", lodCount]));

    for ( Int i = 0; i < lodCount; i++ )
    {
        NPSUXModelLod * lod = [ [ NPSUXModelLod alloc ] initWithParent:self ];

        if ( [ lod loadFromFile:file ] == YES )
        {
            [ lods addObject:lod ];
        }

        [ lod release ];
    }

    ready = YES;

    return YES;
}

- (void) reset
{
    [ lods removeAllObjects ];
    [ materials removeAllObjects ];

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (NSArray *) materials
{
    return materials;
}

- (void) uploadToGL
{
    if ( ready == NO )
    {
        NPLOG(@"model not ready");
        return;
    }

    NSEnumerator * lodEnumerator = [ lods objectEnumerator ];
    NPSUXModelLod * lod;

    while ( ( lod = [ lodEnumerator nextObject ] ) )
    {
        [ lod uploadToGL ];
    }

    NSEnumerator * materialEnumerator = [ materials objectEnumerator ];
    NPSUXMaterialInstance * materialInstance;

    while ( ( materialInstance = [ materialEnumerator nextObject ] ) )
    {
        NSEnumerator * textureEnumerator = [ [ materialInstance textures ] objectEnumerator ];
        NPTexture * texture;

        while ( ( texture = [ textureEnumerator nextObject ] ) )
        {
            [ texture uploadToGL ];
        }
    }
}

- (void) render
{
    if ( ready == NO )
    {
        NPLOG(@"model not ready");
        return;
    }

    [[lods objectAtIndex:0 ] render ];
}

@end
