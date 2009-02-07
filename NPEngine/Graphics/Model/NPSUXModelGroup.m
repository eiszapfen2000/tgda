#import "NPSUXModelGroup.h"
#import "NP.h"

@implementation NPSUXModelGroup

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPSUXModelGroup" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    primitiveType = -1;
    firstIndex    = -1;
    lastIndex     = -1;
    materialInstanceIndex = -1;

    model    = nil;
    material = nil;

    return self;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * groupName = [ file readSUXString ];
    [ self setName:groupName ];
    [ groupName release ];

    [ file readInt32:&primitiveType ];
    [ file readInt32:&firstIndex ];
    [ file readInt32:&lastIndex ];
    [ file readInt32:&materialInstanceIndex ];

    model = (NPSUXModel *)[ parent parent ];
    material = [[ model materials ] objectAtIndex:materialInstanceIndex ];

    ready = YES;

    return YES;
}

- (BOOL) saveToFile:(NPFile *)file
{
    if ( ready == NO )
    {
        return NO;
    }

    [ file writeSUXString:name ];
    [ file writeInt32:&primitiveType ];
    [ file writeInt32:&firstIndex ];
    [ file writeInt32:&lastIndex ];
    [ file writeInt32:&materialInstanceIndex ];

    return YES;
}

- (void) reset
{
    primitiveType = -1;
    firstIndex    = -1;
    lastIndex     = -1;
    materialInstanceIndex = -1;

    [ super reset ];
}

- (void) render
{
    if ( ready == NO )
    {
        NPLOG_WARNING(@"%@: group not ready, cannot render", name);
        return;
    }

    [  material activate ];

    CGpass pass = [[[ material effect ] defaultTechnique ] firstPass ];

    while ( pass )
    {
        cgSetPassState(pass);

        [[(NPSUXModelLod *)parent vertexBuffer ] renderWithPrimitiveType:primitiveType firstIndex:firstIndex andLastIndex:lastIndex ];

        cgResetPassState(pass);
        pass = cgGetNextPass(pass);
    }
}

@end
