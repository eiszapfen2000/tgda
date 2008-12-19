#import "ODEntity.h"
#import "NP.h"

@implementation ODEntity

- (id) init
{
    return [ self initWithName:@"ODEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    position = fv3_alloc();

    return self;
}

- (void) dealloc
{
    [ stateset release ];
    [ model    release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    config = [[ NSMutableDictionary alloc ] initWithContentsOfFile:path ];

    NSString * entityName = [ config objectForKey:@"Name" ];
    NSString * modelPath = [ config objectForKey:@"Model" ];
    NSString * statesetPath = [ config objectForKey:@"States" ];
    NSArray * positionStrings = [ config objectForKey:@"Position" ];

    NSLog(@"%@",[positionStrings description]);

    V_X(*position) = [[ positionStrings objectAtIndex:0 ] floatValue ];
    V_Y(*position) = [[ positionStrings objectAtIndex:1 ] floatValue ];
    V_Z(*position) = [[ positionStrings objectAtIndex:2 ] floatValue ];

    NSLog(@"%f %f %f",V_X(*position),V_Y(*position),V_Z(*position));

    if ( modelPath == nil || statesetPath == nil || entityName == nil )
    {
        return NO;
    }

    [ self setName:entityName ];

    model = [[[[ NP Graphics ] modelManager ] loadModelFromPath:modelPath ] retain ];
    stateset = [[[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:statesetPath ] retain ];

    if ( model == nil || stateset == nil )
    {
        return NO;
    }

    return YES;
}

@end
