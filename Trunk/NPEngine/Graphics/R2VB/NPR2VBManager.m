#import "NPR2VBManager.h"
#import "NPR2VBConfiguration.h"
#import "NP.h"

@implementation NPR2VBManager

- (id) init;
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NP Render 2 Vertexbuffer Manager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    configurations = [[ NSMutableArray alloc ] init ];
    currentConfiguration = nil;
    bufferKeys = [[ NSSet alloc ] initWithObjects:@"Positions", @"Normals", @"Colors", @"Weights", nil ];

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentConfiguration);
    [ configurations removeAllObjects ];
    [ configurations release ];
    [ bufferKeys release ];

    [ super dealloc ];
}

- (NSSet *) bufferKeys
{
    return bufferKeys;
}

- (BOOL) isValidBufferKey:(NSString *)bufferKey
{
    return [ bufferKeys containsObject:bufferKey ];
}

- (NPR2VBConfiguration *) currentConfiguration
{
    return currentConfiguration;
}

- (void) setCurrentConfiguration:(NPR2VBConfiguration *)newCurrentConfiguration
{
    ASSIGN(currentConfiguration, newCurrentConfiguration);
}

- (GLenum) glBufferIdentifierFromNPBufferIdentifier:(NSNumber *)bufferIdentifier
{
    GLenum buffer = GL_NONE;

    switch ( [ bufferIdentifier intValue ] )
    {
        case NP_READ_BUFFER_FRAMEBUFFER_BACK       :{ buffer = GL_BACK;        break; }
        case NP_READ_BUFFER_FRAMEBUFFER_LEFT_BACK  :{ buffer = GL_BACK_LEFT;   break; }
        case NP_READ_BUFFER_FRAMEBUFFER_RIGHT_BACK :{ buffer = GL_BACK_RIGHT;  break; }
        case NP_READ_BUFFER_FRAMEBUFFER_FRONT      :{ buffer = GL_FRONT;       break; }
        case NP_READ_BUFFER_FRAMEBUFFER_LEFT_FRONT :{ buffer = GL_FRONT_LEFT;  break; }
        case NP_READ_BUFFER_FRAMEBUFFER_RIGHT_FRONT:{ buffer = GL_FRONT_RIGHT; break; }

        default:{ NPLOG_ERROR(@"%@: Unknown Color Buffer", name); break; }
    }

    return buffer;
}

@end
