#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
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
    return YES;
}

- (void) update:(const float)frameTime
{
}

- (void) render
{
}

@end

