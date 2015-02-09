#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "NPEngineGraphics.h"
#import "NPViewport.h"
#import "NPOrthographic.h"

@implementation NPOrthographic

+ (float) top
{
    return [[[ NPEngineGraphics instance ] viewport ] top ];
}

+ (float) bottom
{
    return [[[ NPEngineGraphics instance ] viewport ] bottom ];
}

+ (float) left
{
    return [[[ NPEngineGraphics instance ] viewport ] left ];
}

+ (float) right
{
    return [[[ NPEngineGraphics instance ] viewport ] right ];
}

+ (FVector2) topCenter
{
    const float left  = [ NPOrthographic left  ];
    const float right = [ NPOrthographic right ];

    FVector2 result;
    result.y = [ NPOrthographic top ];
    result.x = left + ((right - left) / 2.0f);

    return result;
}

+ (FVector2) bottomCenter
{
    const float left  = [ NPOrthographic left  ];
    const float right = [ NPOrthographic right ];

    FVector2 result;
    result.y = [ NPOrthographic bottom ];
    result.x = left + ((right - left) / 2.0f);

    return result;
}

+ (FVector2) leftCenter
{
    const float top    = [ NPOrthographic top    ];
    const float bottom = [ NPOrthographic bottom ];

    FVector2 result;
    result.x = [ NPOrthographic left ];
    result.y = bottom + ((top - bottom) / 2.0f);

    return result;
}

+ (FVector2) rightCenter
{
    const float top    = [ NPOrthographic top    ];
    const float bottom = [ NPOrthographic bottom ];

    FVector2 result;
    result.x = [ NPOrthographic right ];
    result.y = bottom + ((top - bottom) / 2.0f);

    return result;
}

+ (FVector2) alignTop:(const FVector2)vector
{
    FVector2 aligned = { vector.x, [ self top ] - vector.y };
    return aligned;
}

+ (FVector2) alignBottom:(const FVector2)vector
{
    FVector2 aligned = { vector.x, [ self bottom ] + vector.y };
    return aligned;
}

+ (FVector2) alignLeft:(const FVector2)vector
{
    FVector2 aligned = { [ self left ] + vector.x, vector.y };
    return aligned;
}

+ (FVector2) alignRight:(const FVector2)vector
{
    FVector2 aligned = { [ self right ] - vector.x, vector.y };
    return aligned;
}

+ (FVector2) alignTopLeft:(const FVector2)vector
{
    FVector2 aligned = { [ self left ] + vector.x, [ self top ] - vector.y };
    return aligned;
}

+ (FVector2) alignTopRight:(const FVector2)vector
{
    FVector2 aligned = { [ self right ] - vector.x, [ self top ] - vector.y };
    return aligned;
}

+ (FVector2) alignBottomLeft:(const FVector2)vector
{
    FVector2 aligned = { [ self left ] + vector.x, [ self bottom ] + vector.y };
    return aligned;
}

+ (FVector2) alignBottomRight:(const FVector2)vector
{
    FVector2 aligned = { [ self right ] - vector.x, [ self bottom ] + vector.y };
    return aligned;
}

- (id) init
{
    return [ self initWithName:@"NPOrthographic" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    fm4_m_set_identity(&modelBefore);
    fm4_m_set_identity(&viewBefore);
    fm4_m_set_identity(&projectionBefore);

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) activate
{
    NPTransformationState * tState
        = [[ NPEngineCore instance ] transformationState ];

    modelBefore      = *[ tState modelMatrix      ];
    viewBefore       = *[ tState viewMatrix       ];
    projectionBefore = *[ tState projectionMatrix ];

    FMatrix4 orthoProjection;
    fm4_mssss_orthographic_2d_projection_matrix(&orthoProjection,
        [ NPOrthographic left ], [ NPOrthographic right ],
        [ NPOrthographic bottom ], [ NPOrthographic top ]);

    [ tState resetModelMatrix ];
    [ tState resetViewMatrix  ];
    [ tState setFProjectionMatrix:&orthoProjection ];
}

- (void) deactivate
{
    NPTransformationState * tState
        = [[ NPEngineCore instance ] transformationState ];

    [ tState setFModelMatrix:&modelBefore ];
    [ tState setFViewMatrix:&viewBefore ];
    [ tState setFProjectionMatrix:&projectionBefore ];
}

@end
