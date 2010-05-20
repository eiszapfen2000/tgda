#import "NPSUXMaterialInstance.h"
#import "NPSUXMaterialInstanceCompiler.h"
#import "NP.h"

@implementation NPSUXMaterialInstanceCompiler

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPSUXMaterialInstanceCompiler" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

- (void) dealloc
{
	[ super dealloc ];
}

- (void) parseUsesStatement:(NSUInteger)lineIndex
{
    NSString * effectFileName = nil;

    if ( [ self getTokenAsString:&effectFileName
                        fromLine:lineIndex
                      atPosition:1 ] == YES )
    {
    }
}

- (void) parseSetStatement:(NSUInteger)lineIndex
{
    NSString * token = nil;

    if ( [ self getTokenAsLowerCaseString:&token
                                 fromLine:lineIndex
                               atPosition:1 ] == YES )
    {
        if ( [ token isEqual:@"technique" ] == YES )
        {
            NSString * techniqueName = nil;

            if ( [ self getTokenAsString:&techniqueName
                                 fromLine:lineIndex
                               atPosition:2 ] == YES )
            {
                // set technique
            }
        }
        else
        {
            if ( [ token isEqual:@"texture1D" ] == YES )
            {
            }
            if ( [ token isEqual:@"texture1DsRGB" ] == YES )
            {
            }
            else if ( [ token isEqual:@"texture2D" ] == YES )
            {
            }
            else if ( [ token isEqual:@"texture2DsRGB" ] == YES )
            {
            }
            else if ( [ token isEqual:@"texture3D" ] == YES )
            {
            }
            else if ( [ token isEqual:@"textureCUBE" ] == YES )
            {
            }
            else if ( [ token isEqual:@"textureCUBEsRGB" ] == YES )
            {
            }
        }
    }
}

- (void) parseStatements
{
    for (NSUInteger i = 0; i < [ lines count ]; i++ )
    {
        NSString * token = nil;

        if ( [ self getTokenAsLowerCaseString:&token
                                     fromLine:i
                                   atPosition:0 ] == YES )
        {
            if ( [ token isEqual:@"set" ] == YES )
            {
                [ self parseSetStatement:i ];
            }
            else if ( [ token isEqual:@"uses" ] == YES )
            {
                [ self parseUsesStatement:i ];
            }
        }
    }
}

- (void) compileInformationFromScript:(NPStringList *)inputScript
              intoSUXMaterialInstance:(NPSUXMaterialInstance *)materialInstance
{
    if ( materialInstance == nil )
    {
        NPLOG_ERROR(@"%s - No target material instance supplied", __PRETTY_FUNCTION__);
        return;
    }

    if ( inputScript == nil )
    {
        NPLOG_ERROR(@"%s - No input script supplied", __PRETTY_FUNCTION__);
        return;
    }

    [ self parse:inputScript ];

}

@end
