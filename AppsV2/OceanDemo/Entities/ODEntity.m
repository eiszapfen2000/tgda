#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/State/NPStateSet.h"
#import "ODEntity.h"

NPAssetArray * models = nil;
NPAssetArray * statesets = nil;

@implementation ODEntity

+ (void) initialize
{
    models
        = [[ NPAssetArray alloc ] 
                initWithName:@"Ocean Demo Entity Models"
                  assetClass:NSClassFromString(@"NPSUX2Model") ];

    statesets
        = [[ NPAssetArray alloc ] 
                initWithName:@"Ocean Demo Entity Statesets"
                  assetClass:NSClassFromString(@"NPStateSet") ];
}

- (id) init
{
    return [ self initWithName:@"ODEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    fm4_m_set_identity(&modelMatrix);
    fv3_v_init_with_zeros(&position);

    return self;
}

- (void) dealloc
{
    if ( stateset != nil )
    {
        [ statesets unregisterAsset:stateset ];
        DESTROY(stateset);
    }

    if ( model != nil )
    {
        [ models unregisterAsset:model ];
        DESTROY(model);
    }

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSString * entityName      = [ config objectForKey:@"Name"     ];
    NSString * modelPath       = [ config objectForKey:@"Model"    ];
    NSString * statesetPath    = [ config objectForKey:@"States"   ];
    NSArray  * positionStrings = [ config objectForKey:@"Position" ];

    position.x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] floatValue ];
    position.z = [[ positionStrings objectAtIndex:2 ] floatValue ];

    if ( modelPath == nil || entityName == nil )
    {
        // set error
        return NO;
    }

    [ self setName:entityName ];

    model = [ models getAssetWithFileName:modelPath ];

    if ( model != nil )
    {
        [ models registerAsset:model ];
        RETAIN(model);
    }

    if ( statesetPath != nil )
    {
        stateset = [ statesets getAssetWithFileName:statesetPath ];

        if (stateset != nil )
        {
            [ statesets registerAsset:stateset ];
            RETAIN(stateset);
        }
    }

    if ( model == nil )
    {
        // set error
        return NO;
    }

    return YES;
}

- (NPSUX2Model *) model
{
    return model;
}

- (FVector3 *) position
{
    return &position;
}

- (void) setPosition:(FVector3 *)newPosition
{
    position = *newPosition;
}

- (void) update:(const float)frameTime
{

}

- (void) render
{
    fm4_mv_translation_matrix(&modelMatrix, &position);
    [[[ NPEngineCore instance ] transformationState ] setModelMatrix:&modelMatrix ];

    if ( stateset != nil )
    {
        [ stateset activate ];
    }

    [ model render ];
}

@end
