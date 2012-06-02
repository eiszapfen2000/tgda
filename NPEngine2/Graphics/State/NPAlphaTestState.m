#import "GL/glew.h"
#import "NPAlphaTestState.h"

@implementation NPAlphaTestState

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    alphaThreshold        = 0.5f;
    defaultAlphaThreshold = 0.5f;
    currentAlphaThreshold = 0.6f;

    comparisonFunction        = NpComparisonGreaterEqual;
    defaultComparisonFunction = NpComparisonGreaterEqual;
    currentComparisonFunction = NpComparisonLess;

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

- (Float) alphaThreshold
{
    return alphaThreshold;
}

- (Float) defaultAlphaThreshold
{
    return defaultAlphaThreshold;
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

- (void) setAlphaThreshold:(Float)newAlphaThreshold
{
    if ( [ super changeable ] == YES )
    {
        alphaThreshold = newAlphaThreshold;
    }
}

- (void) setDefaultAlphaThreshold:(Float)newDefaultAlphaThreshold
{
    defaultAlphaThreshold = newDefaultAlphaThreshold;
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
            glEnable(GL_ALPHA_TEST);
        }
        else
        {
            glDisable(GL_ALPHA_TEST);
        }
    }

    if ( enabled == YES )
    {
        if (( currentAlphaThreshold != alphaThreshold )
            || (currentComparisonFunction != comparisonFunction))
        {
            currentAlphaThreshold     = alphaThreshold;
            currentComparisonFunction = comparisonFunction;

            GLenum comparison
                = getGLComparisonFunction(currentComparisonFunction);

            glAlphaFunc(comparison, alphaThreshold);
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
        alphaThreshold     = defaultAlphaThreshold;
        comparisonFunction = defaultComparisonFunction;
    }
}


@end
