#import "NPSUXMaterialInstance.h"

@implementation NPSUXMaterialInstance

- (id) init
{
    return [ self initWithName:@"NPSUXMaterialInstance" parent:nil ];
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

- (void) loadFromFile:(NPFile *)file
{
    NSString * materialInstanceName = [ file readSUXString ];
    [ self setName:materialInstanceName ];
    [ materialInstanceName release ];

    NSString * materialScriptFileName = [ file readSUXString ];
    [ self setMaterialFileName:materialScriptFileName ];
    [ materialScriptFileName release ];

    materialInstanceScript = [ file readSUXScript ];
}

@end
