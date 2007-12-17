#import <string.h>

#import "NPSUXModel.h"

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

    NSString * modelName = [ [ file readSUXString ] retain ];
    [ self setName:modelName ];
    NSLog(modelName);

    [ modelName release ];

    Int materialCount = 0;
    [ file readInt32:&materialCount ];
    NSLog(@"%d",materialCount);
}

@end
