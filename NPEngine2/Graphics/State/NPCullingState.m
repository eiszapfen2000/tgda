#import "NPCullingState.h"

@implementation NPCullingState

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent 
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName parent:newParent configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    cullFace        = NpCullfaceBack;
    defaultCullFace = NpCullfaceBack;
    currentCullFace = NpCullfaceFront;

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

- (NpCullface) cullFace
{
    return cullFace;
}

- (NpCullface) defaultCullFace
{
    return defaultCullFace;
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

- (void) setCullFace:(NpCullface)newCullFace
{
    if ( [ super changeable ] == YES )
    {
        cullFace = newCullFace;
    }
}

- (void) setDefaultCullFace:(NpCullface)newDefaultCullFace
{
    defaultCullFace = newDefaultCullFace;
}

- (void) activate
{
    if ( [ super changeable ] == NO )
    {
         return;
    }

    //if ( currentlyEnabled != enabled )
    {
        currentlyEnabled = enabled;

        if ( enabled == YES )
        {
            glEnable(GL_CULL_FACE);
        }
        else
        {
            glDisable(GL_CULL_FACE);
        }
    }

    if ( enabled == YES )
    {
        //if ( currentCullFace != cullFace )
        {
            currentCullFace = cullFace;
            GLenum face = getGLCullface(currentCullFace);
            glCullFace(face);
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
        enabled  = defaultEnabled;
        cullFace = defaultCullFace;
    }
}


@end
