#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Timer/NPTimer.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/State/NPStateSet.h"
#import "ODTerrain.h"

@implementation ODTerrain

- (id) init
{
    return [ self initWithName:@"ODTerrain" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    models = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ models removeAllObjects ];
    DESTROY(models);
    SAFE_DESTROY(stateset);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSAssert(config != nil, @"");

    NSString * entityName   = [ config objectForKey:@"Name"   ];
    NSString * statesetPath = [ config objectForKey:@"States" ];
    NSArray  * modelStrings = [ config objectForKey:@"Models" ];

    if ( modelStrings == nil || entityName == nil )
    {
        // set error
        return NO;
    }

    [ self setName:entityName ];

    const NSUInteger numberOfModelFiles = [ modelStrings count ];
    for ( NSUInteger i = 0; i < numberOfModelFiles; i++ )
    {
        NPSUX2Model * model = [[ NPSUX2Model alloc ] init ];

        if ( [ model loadFromFile:[ modelStrings objectAtIndex:i ]
                        arguments:nil
                            error:error ] == YES )
        {
            [ models addObject:model ];
        }

        DESTROY(model);
    }

    if ( statesetPath != nil )
    {
        stateset = [[ NPStateSet alloc ] initWithName:@"Terrain States" ];

        if ( [ stateset loadFromFile:statesetPath
                           arguments:nil
                               error:error ] == NO )
        {
            DESTROY(stateset);
            return NO;
        }
    }

    return YES;
}

- (void) update:(const double)frameTime
{
}

- (void) render
{
    const NSUInteger numberOfModels = [ models count ];
    for ( NSUInteger i = 0; i < numberOfModels; i++ )
    {
        [[ models objectAtIndex:i ] renderLOD:0 withMaterial:NO ];
    }
}

@end

