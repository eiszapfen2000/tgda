#import "NPDepthTestState.h"

@implementation NPDepthTestState

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    writeEnabled        = YES;
    defaultWriteEnabled = YES;
    currentWriteEnabled = NO;

    comparisonFunction        = NpComparisonLessEqual;
    defaultComparisonFunction = NpComparisonLessEqual;
    currentComparisonFunction = NpComparisonGreater;

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

- (BOOL) defaultEnabled
{
    return defaultEnabled;
}

- (BOOL) writeEnabled
{
    return writeEnabled;
}

- (BOOL) defaultWriteEnabled
{
    return defaultWriteEnabled;
}

- (NpComparisonFunction) comparisonFunction
{
    return comparisonFunction;
}

- (NpComparisonFunction) defaultComparisonFunction
{
    return defaultComparisonFunction;
}

- (void) setEnabled:(BOOL)newEnabled
{
    if ( [ super changeable ] == YES )
    {
        enabled = newEnabled;
    }
}

- (void) setDefaultEnabled:(BOOL)newDefaultEnabled
{
    defaultEnabled = newDefaultEnabled;
}

- (void) setWriteEnabled:(BOOL)newWriteEnabled
{
    if ( [ super changeable ] == YES )
    {
        writeEnabled = newWriteEnabled;
    }
}

- (void) setDefaultWriteEnabled:(BOOL)newDefaultWriteEnabled
{
    defaultWriteEnabled = newDefaultWriteEnabled;
}

- (void) setComparisonFunction:(NpComparisonFunction)newComparisonFunction
{
    if ( [ super changeable ] == YES )
    {
        comparisonFunction = newComparisonFunction;
    }
}

- (void) setDefaultComparisonFunction:(NpComparisonFunction)newDefaultComparisonFunction
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

    if ( currentWriteEnabled != writeEnabled )
    {
        currentWriteEnabled = writeEnabled;
        glDepthMask(writeEnabled);
    }

    if ( enabled == YES )
    {
        if ( currentComparisonFunction != comparisonFunction )
        {
            currentComparisonFunction = comparisonFunction;
            GLenum comparison
                = getGLComparisonFunction(currentComparisonFunction);

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
