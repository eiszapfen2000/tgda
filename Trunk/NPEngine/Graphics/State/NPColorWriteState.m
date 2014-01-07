#import "NPColorWriteState.h"
//#import "NP.h"

@implementation NPColorWriteState

- (id) init
{
    return [ self initWithName:@"NP Color Write State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:newParent configuration:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName parent:newParent configuration:newConfiguration ];

    currentEnabled = NO;
    enabled = YES;
    defaultEnabled = YES;

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
    if ( [ super changeable ] == YES )
    {
        defaultEnabled = newDefaultEnabled;
    }
}

- (void) activate
{
    if ( [ super changeable ] == NO )
    {
         return;
    }

    if ( currentEnabled != enabled )
    {
        currentEnabled = enabled;

        if ( enabled == YES )
        {
            glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
        }
        else
        {
            glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
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
        enabled = defaultEnabled;
    }
}


@end
