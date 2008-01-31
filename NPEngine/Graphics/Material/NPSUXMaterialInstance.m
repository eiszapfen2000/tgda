#import "NPSUXMaterialInstance.h"
#import "Core/Utilities/NPStringUtilities.h"

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

- (void) parseMaterialInstanceScript
{
	NSCharacterSet * set = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];

	for ( Int i = 0; i < [ materialInstanceScript count ]; i++ )
	{
		NSMutableArray * elements = splitStringUsingCharacterSet([ materialInstanceScript objectAtIndex:i ], set);
	}	
}


- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * materialInstanceName = [ file readSUXString ];
    [ self setName:materialInstanceName ];
    [ materialInstanceName release ];

    NSString * materialScriptFileName = [ file readSUXString ];
    [ self setMaterialFileName:materialScriptFileName ];
    [ materialScriptFileName release ];

    materialInstanceScript = [ file readSUXScript ];

	[ self parseMaterialInstanceScript ];

    return YES;
}

- (void) reset
{
    [ materialFileName release ];
    materialFileName = @"";

    [ materialInstanceScript removeAllObjects ];

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

@end
