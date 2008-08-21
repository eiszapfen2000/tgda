#import "NPSUXModelGroup.h"
#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/Model/NPSUXModelLod.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Material/NPSUXMaterialInstance.h"
#import "Graphics/Material/NPEffect.h"
#import "Core/NPEngineCore.h"

@implementation NPSUXModelGroup

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPSUXModelGroup" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    primitiveType = -1;
    firstIndex = -1;
    lastIndex = -1;
    materialInstanceIndex = -1;

    model = nil;
    material = nil;

    return self;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * groupName = [ file readSUXString ];
    [ self setName:groupName ];
    [ groupName release ];
    NPLOG(([NSString stringWithFormat:@"Group Name: %@", name]));

    [ file readInt32:&primitiveType ];

    [ file readInt32:&firstIndex ];
    NPLOG(([NSString stringWithFormat:@"First Index: %d", firstIndex]));
    [ file readInt32:&lastIndex ];
    NPLOG(([NSString stringWithFormat:@"Last Index: %d", lastIndex]));

    [ file readInt32:&materialInstanceIndex ];
    NPLOG(([NSString stringWithFormat:@"Material Instance Index: %d", materialInstanceIndex]));

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
    firstIndex = -1;
    lastIndex = -1;
    materialInstanceIndex = -1;

    [ super reset ];
}

- (void) render
{
    if ( ready == NO )
    {
        NPLOG(@"group not ready");
        return;
    }

    [  material activate ];

    CGpass pass = cgGetFirstPass([[ material effect ] defaultTechnique]);

    while (pass)
    {
        cgSetPassState(pass);

        [[(NPSUXModelLod *)parent vertexBuffer ] renderElementWithPrimitiveType:primitiveType firstIndex:firstIndex andLastIndex:lastIndex ];

        cgResetPassState(pass);
        pass = cgGetNextPass(pass);
    }
}

@end
