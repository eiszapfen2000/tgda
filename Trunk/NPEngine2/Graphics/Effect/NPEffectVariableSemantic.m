#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Core/World/NPTransformationState.h"
#import "NPEffectTechniqueVariable.h"
#import "NPEffectVariableSemantic.h"

@implementation NPEffectVariableSemantic

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
           semantic:(NpEffectSemantic)newSemantic
{
    self = [ super initWithName:newName
                   variableType:NpEffectVariableTypeSemantic ];

    semantic = newSemantic;

    return self;
}

- (NpEffectSemantic) semantic
{
    return semantic;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    NPTransformationState * trafo = [[ NPEngineCore instance ] transformationState ];
    GLint location = [ variable location ];
    FMatrix4 * m = NULL;

    switch ( semantic )
    {
        case NpModelMatrix:
        {
            m = [ trafo modelMatrix ];
            break;
        }

        case NpInverseModelMatrix:
        {
            m = [ trafo inverseModelMatrix ];
            break;
        }

        case NpViewMatrix:
        {
            m = [ trafo viewMatrix ];
            break;
        }

        case NpInverseViewMatrix:
        {
            m = [ trafo inverseViewMatrix ];
            break;
        }

        case NpProjectionMatrix:
        {
            m = [ trafo projectionMatrix ];
            break;
        }

        case NpInverseProjectionMatrix:
        {
            m = [ trafo inverseProjectionMatrix ];
            break;
        }

        case NpModelViewMatrix:
        {
            m = [ trafo modelViewMatrix ];
            break;
        }

        case NpInverseModelViewMatrix:
        {
            m = [ trafo inverseModelViewMatrix ];
            break;
        }

        case NpViewProjectionMatrix:
        {
            m = [ trafo viewProjectionMatrix ];
            break;
        }

        case NpInverseViewProjectionMatrix:
        {
            m = [ trafo inverseViewProjectionMatrix ];
            break;
        }

        case NpModelViewProjectionMatrix:
        {
            m = [ trafo modelViewProjectionMatrix ];
            break;
        }

        case NpInverseModelViewProjection:
        {
            m = [ trafo inverseModelViewProjectionMatrix ];
            break;
        }

        default:
        {
            NPLOG(@"%s Unknown semantic variable %@", __PRETTY_FUNCTION__, name);
            break;
        }

    }

    if ( m != NULL )
    {
        glUniformMatrix4fv(location, 1, GL_FALSE, (const GLfloat *)m->elements);
    }
}


@end

