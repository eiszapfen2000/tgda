#import "NPOrthographicRendering.h"
#import "NP.h"

@implementation NPOrthographicRendering

+ (Float) top
{
    return 1.0f;
}

+ (Float) bottom
{
    return -1.0f;
}

+ (Float) left
{
    return -[[[[ NP Graphics ] viewportManager ] currentViewport ] aspectRatio ];
}

+ (Float) right
{
    return [[[[ NP Graphics ] viewportManager ] currentViewport ] aspectRatio ];
}

+ (FVector2) alignTop:(FVector2)vector
{
    FVector2 aligned = { vector.x, [ self top ] - vector.y };
    return aligned;
}

+ (FVector2) alignBottom:(FVector2)vector
{
    FVector2 aligned = { vector.x, [ self bottom ] + vector.y };
    return aligned;
}

+ (FVector2) alignLeft:(FVector2)vector
{
    FVector2 aligned = { [ self left ] + vector.x, vector.y };
    return aligned;
}

+ (FVector2) alignRight:(FVector2)vector
{
    FVector2 aligned = { [ self right ] - vector.x, vector.y };
    return aligned;
}

+ (FVector2) alignTopLeft:(FVector2)vector
{
    FVector2 aligned = { [ self left ] + vector.x, [ self top ] - vector.y };
    return aligned;
}

+ (FVector2) alignTopRight:(FVector2)vector
{
    FVector2 aligned = { [ self right ] - vector.x, [ self top ] - vector.y };
    return aligned;
}

+ (FVector2) alignBottomLeft:(FVector2)vector
{
    FVector2 aligned = { [ self left ] + vector.x, [ self bottom ] + vector.y };
    return aligned;
}

+ (FVector2) alignBottomRight:(FVector2)vector
{
    FVector2 aligned = { [ self right ] - vector.x, [ self bottom ] + vector.y };
    return aligned;
}

- (id) init
{
    return [ self initWithName:@"NPOrthographicRendering" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    tmpModelMatrix = fm4_alloc_init();;
    tmpViewMatrix  = fm4_alloc_init();;
    tmpProjectionMatrix = fm4_alloc_init();;

    modelMatrix = fm4_alloc_init();
    viewMatrix  = fm4_alloc_init();
    projectionMatrix = fm4_alloc_init();

    return self;
}

- (void) dealloc
{
    fm4_free(projectionMatrix);
    fm4_free(viewMatrix);
    fm4_free(modelMatrix);

    [ super dealloc ];
}

- (void) activate
{
    transformationStateToModifiy = [[[ NP Core ] transformationStateManager ] currentTransformationState ];

    *tmpModelMatrix      = *[ transformationStateToModifiy modelMatrix ];
    *tmpViewMatrix       = *[ transformationStateToModifiy viewMatrix ];
    *tmpProjectionMatrix = *[ transformationStateToModifiy projectionMatrix ];

    Float aspectRatio = [[[[ NP Graphics ] viewportManager ] currentViewport ] aspectRatio ];
    fm4_ms_simple_orthographic_projection_matrix(projectionMatrix, aspectRatio);

    [ transformationStateToModifiy setModelMatrix:modelMatrix ];
    [ transformationStateToModifiy setViewMatrix:viewMatrix ];
    [ transformationStateToModifiy setProjectionMatrix:projectionMatrix ];
}

- (void) deactivate
{
    [ transformationStateToModifiy setModelMatrix:tmpModelMatrix ];
    [ transformationStateToModifiy setViewMatrix:tmpViewMatrix ];
    [ transformationStateToModifiy setProjectionMatrix:tmpProjectionMatrix ]; 
}

@end

