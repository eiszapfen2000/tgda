#import "NPBlendingState.h"

@implementation NPBlendingState

- (id) initWithName:(NSString *)newName 
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    blendingMode        = NpBlendingAverage;
    defaultBlendingMode = NpBlendingAverage;
    currentBlendingMode = NpBlendingMax;

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

- (NpBlendingMode) blendingMode
{
    return blendingMode;
}

- (NpBlendingMode) defaultBlendingMode
{
    return defaultBlendingMode;
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

- (void) setBlendingMode:(NpBlendingMode)newBlendingMode
{
    if ( [ super changeable ] == YES )
    {
        blendingMode = newBlendingMode;
    }
}

- (void) setDefaultBlendingMode:(NpBlendingMode)newBlendingMode
{
    defaultBlendingMode = newBlendingMode;
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
            glEnable(GL_BLEND);
        }
        else
        {
            glDisable(GL_BLEND);
        }
    }

    if ( enabled == YES )
    {
        if ( currentBlendingMode != blendingMode )
        {
            currentBlendingMode = blendingMode;

            GLenum blendEquation     = GL_FUNC_ADD;
            GLenum sourceFactor      = GL_ONE;
            GLenum destinationFactor = GL_ONE;

            switch ( blendingMode )
            {
                case NpBlendingAdditive:
                {
                    blendEquation = GL_FUNC_ADD;
                    sourceFactor = GL_SRC_ALPHA;
                    destinationFactor = GL_ONE;
                    break;
                }

                case NpBlendingAverage:
                {
                    blendEquation = GL_FUNC_ADD;
                    sourceFactor = GL_SRC_ALPHA;
                    destinationFactor = GL_ONE_MINUS_SRC_ALPHA;
                    break;
                }

                case NpBlendingSubtractive:
                {
                    blendEquation = GL_FUNC_SUBTRACT;
                    sourceFactor = GL_SRC_ALPHA;
                    destinationFactor = GL_ONE;
                    break;
                }

                case NpBlendingMin:
                {
                    blendEquation = GL_MIN;
                    sourceFactor = GL_SRC_COLOR;
                    destinationFactor = GL_DST_COLOR;
                    break;
                }

                case NpBlendingMax:
                {
                    blendEquation = GL_MAX;
                    sourceFactor = GL_SRC_COLOR;
                    destinationFactor = GL_DST_COLOR;
                    break;
                }
            }

            glBlendEquation(blendEquation);
            glBlendFunc(sourceFactor, destinationFactor); 
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
        enabled      = defaultEnabled;
        blendingMode = defaultBlendingMode;
    }
}


@end
