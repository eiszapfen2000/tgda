#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Core/World/NPTransformationState.h"
#import "NPEffectTechniqueVariable.h"
#import "NPEffectVariableSemantic.h"

@implementation NPEffectVariableSemantic

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName
                         parent:newParent
                   variableType:NpEffectVariableTypeSemantic ];

    semantic = NpSemanticUnknown;

    return self;
}

- (NpEffectSemantic) semantic
{
    return semantic;
}

- (void) setSemantic:(NpEffectSemantic)newSemantic
{
    semantic = newSemantic;
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
            FMatrix4 * m = [ trafo inverseViewMatrix ];
            glUniformMatrix4fv(location, 1, GL_FALSE, (const GLfloat *)m->elements);
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
        NSLog(@"activate %@ at %d", name, location);
        glUniformMatrix4fv(location, 1, GL_FALSE, (const GLfloat *)m->elements);
    }
}


@end

