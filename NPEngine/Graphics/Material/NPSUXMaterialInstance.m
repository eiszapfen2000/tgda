#import "NPSUXMaterialInstance.h"

@implementation NPSUXMaterialInstance

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPSUXMaterialInstance" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    materialFileName = @"";
    materialInstanceScript = nil;

    return self;
}

- (NSString *)materialFileName
{
    return materialFileName;
}

- (void) setMaterialFileName:(NSString *)newMaterialFileName
{
    if ( materialFileName != newMaterialFileName )
    {
        [ materialFileName release ];
        materialFileName = [ newMaterialFileName retain ];
    }
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * materialInstanceName = [ file readSUXString ];

    if ( materialInstanceName == nil )
    {
        return NO;
    }

    [ self setName:materialInstanceName ];
    [ materialInstanceName release ];

    NSString * materialScriptFileName = [ file readSUXString ];

    if ( materialScriptFileName == nil )
    {
        return NO;
    }

    [ self setMaterialFileName:materialScriptFileName ];
    [ materialScriptFileName release ];

    materialInstanceScript = [ file readSUXScript ];

    if ( materialInstanceScript == nil )
    {
        return NO;
    }

    return YES;
}

- (void) reset
{
    [ super reset ];

    [ materialFileName release ];
    materialFileName = @"";

    [ materialInstanceScript removeAllObjects ];
}

- (BOOL) isReady
{
    return ready;
}

@end
