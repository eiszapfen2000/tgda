#import <string.h>

#import "NPSUXModel.h"
#import "NPSUXModelLod.h"
#import "Graphics/Material/NPSUXMaterialInstance.h"

@implementation NPSUXModel

- (id) init
{
    return [ self initWithName:@"SUX Model" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    lods = [ [ NSMutableArray alloc ] init ];
    materials = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) loadFromFile:(NPFile *)file
{
    Char suxHeader[8] = "SUX____1";

    Char headerFromFile[8];
    [ file readChars:headerFromFile withLength:8 ];

    if ( strncmp(suxHeader,headerFromFile,8) != 0 )
    {
        NSLog(@"wrong header version");

        return;
    }

    NSString * modelName = [ file readSUXString ];
    [ self setName:modelName ];
    NSLog(@"Model Name: %@",modelName);

    [ modelName release ];

    Int materialCount = 0;
    [ file readInt32:&materialCount ];
    NSLog(@"Material Count: %d",materialCount);

    for ( Int i = 0; i < materialCount; i++ )
    {
        NPSUXMaterialInstance * materialInstance = [ [ NPSUXMaterialInstance alloc ] init ];
        [ materialInstance loadFromFile:file ];
        [ materials addObject:materialInstance ];
        [ materialInstance release ];
    }

    Int lodCount = 0;
    [ file readInt32:&lodCount ];
    NSLog(@"LOD count: %d",lodCount);

    for ( Int i = 0; i < lodCount; i++ )
    {
        NPSUXModelLod * lod = [ [ NPSUXModelLod alloc ] initWithParent:self ];
        [ lod loadFromFile:file ];
        [ lods addObject:lod ];
        [ lod release ];
    }

}

@end
