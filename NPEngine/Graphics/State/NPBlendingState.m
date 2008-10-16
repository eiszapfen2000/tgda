#import "NPBlendingState.h"
#import "Core/NPEngineCore.h"

@implementation NPBlendingState

- (id) init
{
    return [ self initWithName:@"NP Blending State" ];
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

    blendingMode        = NP_BLENDING_AVERAGE;
    defaultBlendingMode = NP_BLENDING_AVERAGE;
    currentBlendingMode = NP_BLENDING_ADDITIVE;

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

- (NpState) blendingMode
{
    return blendingMode;
}

- (void) setBlendingMode:(NpState)newBlendingMode
{
    if ( [ super changeable ] == YES )
    {
        blendingMode = newBlendingMode;
    }
}

- (NpState) defaultBlendingMode
{
    return defaultBlendingMode;
}

- (void) setDefaultBlendingMode:(NpState)newBlendingMode
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
                case NP_BLENDING_ADDITIVE: { blendEquation = GL_FUNC_ADD;      sourceFactor = GL_SRC_ALPHA; destinationFactor = GL_ONE;                 break; }
                case NP_BLENDING_AVERAGE : { blendEquation = GL_FUNC_ADD;      sourceFactor = GL_SRC_ALPHA; destinationFactor = GL_ONE_MINUS_SRC_ALPHA; break; }
                case NP_BLENDING_NEGATIVE: { blendEquation = GL_FUNC_SUBTRACT; sourceFactor = GL_SRC_ALPHA; destinationFactor = GL_ONE;                 break; }
                case NP_BLENDING_MIN     : { blendEquation = GL_MIN;           sourceFactor = GL_SRC_COLOR; destinationFactor = GL_DST_COLOR;           break; }
                case NP_BLENDING_MAX     : { blendEquation = GL_MAX;           sourceFactor = GL_SRC_COLOR; destinationFactor = GL_DST_COLOR;           break; }
                default:{NPLOG_ERROR(@"Unknown blending mode specified"); break; }
            }

            glBlendEquation(blendEquation);
            glBlendFunc(sourceFactor,destinationFactor); 
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
