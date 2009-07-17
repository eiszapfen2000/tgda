#import "NPOrthographicRendering.h"
#import "NP.h"

@implementation NPOrthographicRendering

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

    *tmpModelMatrix = *[ transformationStateToModifiy modelMatrix ];
    *tmpViewMatrix = *[ transformationStateToModifiy viewMatrix ];
    *tmpProjectionMatrix = *[ transformationStateToModifiy projectionMatrix ];

    fm4_mssss_orthographic_2d_projection_matrix(projectionMatrix, 0.0f, 1.0f, 0.0f, 1.0f);

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

