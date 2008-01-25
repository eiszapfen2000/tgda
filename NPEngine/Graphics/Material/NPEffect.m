#import "NPEffect.h"
#import "NPEffectManager.h"

@implementation NPEffect

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPEffect" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    if ( [ newParent isMemberOfClass:[ NPEffectManager class ] ] == NO )
    {
        NSLog(@"das wird schief gehen");
    }

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName: [ file fileName ] ];

    effect = cgCreateEffect( [ (NPEffectManager *)parent cgContext ], [ [ file readEntireFile ] bytes ], NULL );

    if ( effect == NULL )
    {
        return NO;
    }

    return YES;
}

- (void) reset
{
    cgDestroyEffect(effect);

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

@end
