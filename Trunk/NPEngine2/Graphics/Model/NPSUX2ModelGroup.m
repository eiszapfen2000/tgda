#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPSUX2VertexBuffer.h"
#import "NPSUX2Model.h"
#import "NPSUX2MaterialInstance.h"
#import "NPSUX2ModelLOD.h"
#import "NPSUX2ModelGroup.h"

@implementation NPSUX2ModelGroup

- (id) init
{
    return [ self initWithName:@"NPSUX2ModelGroup" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    primitiveType = NpPrimitiveUnknown;
    firstIndex = lastIndex = -1;
    materialInstanceIndex = -1;

    lod = nil;

    return self;
}

- (void) dealloc
{
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

- (NPSUX2ModelLOD *) lod
{
    return lod;
}

- (void) setLod:(NPSUX2ModelLOD *)newLod
{
    // weak reference
    lod = newLod;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    NSString * groupName;
    [ stream readSUXString:&groupName];
    [ self setName:groupName ];

    [ stream readInt32:&primitiveType ];
    [ stream readInt32:&firstIndex ];
    [ stream readInt32:&lastIndex ];
    [ stream readInt32:&materialInstanceIndex ];

    materialInstance
        = [[ lod model ] materialInstanceAtIndex:materialInstanceIndex ];

    ready = (firstIndex != -1 && lastIndex != -1
                && lod != nil && materialInstance != nil);

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

- (void) render
{
    [ self renderWithMaterial:YES ];
}

- (void) renderWithMaterial:(BOOL)renderMaterial
{
    if ( ready == NO )
    {
        NPLOG(@"Group not ready");
        return;
    }

    if ( renderMaterial == YES )
    {
        [ materialInstance activate ];
    }

    [[ lod vertexBuffer ]
            renderWithPrimitiveType:primitiveType
                         firstIndex:firstIndex
                          lastIndex:lastIndex ];
}

@end

