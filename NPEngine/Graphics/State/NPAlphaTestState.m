#import "NPAlphaTestState.h"
#import "NP.h"

@implementation NPAlphaTestState

- (id) init
{
    return [ self initWithName:@"NP Alpha Test State" ];
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

    alphaThreshold        = 0.5f;
    defaultAlphaThreshold = 0.5f;
    currentAlphaThreshold = 0.6f;

    comparisonFunction        = NP_COMPARISON_GREATER_EQUAL;
    defaultComparisonFunction = NP_COMPARISON_GREATER_EQUAL;
    currentComparisonFunction = NP_COMPARISON_LESS;

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

- (Float) alphaThreshold
{
    return alphaThreshold;
}

- (void)  setAlphaThreshold:(Float)newAlphaThreshold
{
    if ( [ super changeable ] == YES )
    {
        alphaThreshold = newAlphaThreshold;
    }
}

- (Float) defaultAlphaThreshold
{
    return defaultAlphaThreshold;
}

- (void)  setDefaultAlphaThreshold:(Float)newDefaultAlphaThreshold
{
    defaultAlphaThreshold = newDefaultAlphaThreshold;
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
            glEnable(GL_ALPHA_TEST);
        }
        else
        {
            glDisable(GL_ALPHA_TEST);
        }
    }

    if ( enabled == YES )
    {
        GLenum comparison = GL_ALWAYS;

        if ( (currentAlphaThreshold != alphaThreshold) || (currentComparisonFunction != comparisonFunction) )
        {
            currentAlphaThreshold     = alphaThreshold;
            currentComparisonFunction = comparisonFunction;

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
