#import "NPDepthTestState.h"
#import "NP.h"

@implementation NPDepthTestState

- (id) init
{
    return [ self initWithName:@"NP Depth Test State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:nil configuration:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName parent:newParent configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    writeEnabled        = YES;
    defaultWriteEnabled = YES;
    currentWriteEnabled = NO;

    comparisonFunction        = NP_COMPARISON_LESS_EQUAL;
    defaultComparisonFunction = NP_COMPARISON_LESS_EQUAL;
    currentComparisonFunction = NP_COMPARISON_GREATER;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) enabled
{
    return enabled;
}

- (void) setEnabled:(BOOL)newEnabled
{
    if ( [ super changeable ] == YES )
    {
        enabled = newEnabled;
    }
}

- (BOOL) defaultEnabled
{
    return defaultEnabled;
}

- (void) setDefaultEnabled:(BOOL)newDefaultEnabled
{
    defaultEnabled = newDefaultEnabled;
}

- (BOOL) writeEnabled
{
    return writeEnabled;
}

- (void) setWriteEnabled:(BOOL)newWriteEnabled
{
    if ( [ super changeable ] == YES )
    {
        writeEnabled = newWriteEnabled;
    }
}

- (BOOL) defaultWriteEnabled
{
    return defaultWriteEnabled;
}

- (void) setDefaultWriteEnabled:(BOOL)newDefaultWriteEnabled
{
    if ( [ super changeable ] == YES )
    {
        defaultWriteEnabled = newDefaultWriteEnabled;
    }
}

- (NpState) comparisonFunction
{
    return comparisonFunction;
}

- (void) setComparisonFunction:(NpState)newComparisonFunction
{
    if ( [ super changeable ] == YES )
    {
        comparisonFunction = newComparisonFunction;
    }
}

- (NpState) defaultComparisonFunction
{
    return defaultComparisonFunction;
}

- (void) setDefaultComparisonFunction:(NpState)newDefaultComparisonFunction
{
    defaultComparisonFunction = newDefaultComparisonFunction;
}

- (void) activate
{
    if ( [ super changeable ] == NO )
    {
         return;
    }

    if ( currentlyEnabled != enabled )
    {
        currentlyEnabled = enabled;

        if ( enabled == YES )
        {
            glEnable(GL_DEPTH_TEST);
        }
        else
        {
            glDisable(GL_DEPTH_TEST);
        }
    }

    if ( enabled == YES )
    {
        if ( currentWriteEnabled != writeEnabled )
        {
            currentWriteEnabled = writeEnabled;
            glDepthMask(writeEnabled);
        }

        if ( currentComparisonFunction != comparisonFunction )
        {
            currentComparisonFunction = comparisonFunction;
            GLenum comparison = GL_LEQUAL;

            switch ( comparisonFunction )
            {
                case NP_COMPARISON_NEVER        : { comparison = GL_NEVER;   break; }
                case NP_COMPARISON_ALWAYS       : { comparison = GL_ALWAYS;  break; }
                case NP_COMPARISON_LESS         : { comparison = GL_LESS;    break; }
                case NP_COMPARISON_LESS_EQUAL   : { comparison = GL_LEQUAL;  break; }
                case NP_COMPARISON_EQUAL        : { comparison = GL_EQUAL;   break; }
                case NP_COMPARISON_GREATER      : { comparison = GL_GREATER; break; }
                case NP_COMPARISON_GREATER_EQUAL: { comparison = GL_GEQUAL;  break; }
                default: { NPLOG_ERROR(@"Unknown alpha test function"); return; }
            }

            glDepthFunc(comparison);
        }
    }
}

- (void) deactivate
{
    if ( [ super changeable ] == YES )
    {
        [ self reset ];
        [ self activate ];
    }
}

- (void) reset
{
    if ( [ super changeable ] == YES )
    {
        enabled            = defaultEnabled;
        writeEnabled       = defaultWriteEnabled;
        comparisonFunction = defaultComparisonFunction;
    }
}


@end
