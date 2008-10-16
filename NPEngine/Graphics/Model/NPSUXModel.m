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

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NP SUX Model" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    lods = [[ NSMutableArray alloc ] init ];
    materials = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ materials removeAllObjects ];
	[ materials release ];
    [ lods removeAllObjects ];
	[ lods release ];

	[ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    Char * suxHeader = "SUX____1";

    Char headerFromFile[8];
    [ file readChars:headerFromFile withLength:8 ];

    if ( strncmp(suxHeader, headerFromFile, 8) != 0 )
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
        NPSUXMaterialInstance * materialInstance = [[ NPSUXMaterialInstance alloc ] init ];

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

- (BOOL) saveToFile:(NPFile *)file
{
    Char suxHeader[8] = "SUX____1";
    [ file writeChars:suxHeader withLength:8 ];

    [ file writeSUXString:name ];

    Int32 materialCount = (Int32)[ materials count ];
    [ file writeInt32:&materialCount ];

    for ( Int i = 0; i < materialCount; i++ )
    {
        NPSUXMaterialInstance * materialInstance = [ materials objectAtIndex:i ];

        if ( [ materialInstance saveToFile:file ] == NO )
        {
            return NO;
        }
    }

    Int32 lodCount = (Int32)[ lods count ];
    [ file writeInt32:&lodCount ];

    for ( Int i = 0; i < lodCount; i++ )
    {
        NPSUXModelLod * lod = [ lods objectAtIndex:i ];

        if ( [ lod saveToFile:file ] == NO )
        {
            return NO;
        }
    }

    return YES;
}

- (void) reset
{
    [ lods removeAllObjects ];
    [ materials removeAllObjects ];

    [ super reset ];
}

- (NSArray *) lods
{
    return lods;
}

- (NSArray *) materials
{
    return materials;
}

- (void) addLod:(NPSUXModelLod *)newLod
{
    [ lods addObject:newLod ];
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

    //NSLog(@"%d",[lods retainCount]);
    //[ lods release ];
    //NSLog(@"%d",[lods retainCount]);

    /*NSEnumerator * materialEnumerator = [ materials objectEnumerator ];
    NPSUXMaterialInstance * materialInstance;

    while ( ( materialInstance = [ materialEnumerator nextObject ] ) )
    {
        NSEnumerator * textureEnumerator = [ [ materialInstance textures ] objectEnumerator ];
        NPTexture * texture;

        while ( ( texture = [ textureEnumerator nextObject ] ) )
        {
            glBindTexture(GL_TEXTURE_2D,[texture textureID]);
            [ texture setMipMapping:NP_TEXTURE_FILTER_MIPMAPPING_ACTIVE ];
            [ texture uploadToGL ];
            [ texture setTextureMaxFilter:NP_TEXTURE_FILTER_LINEAR ];
            [ texture setTextureMinFilter:NP_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR ];
        }
    }*/
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
