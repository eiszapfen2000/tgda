#import "Core/Basics/NpMemory.h"
#import "Log/NPLog.h"
#import "NPTextureBindingState.h"

@implementation NPTextureBindingState

- (id) init
{
    return [ self initWithName:@"NPEngine TextureBinding State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    locked = NO;
    numberOfSuppertedTexelUnits = maximumNumberOfVertexTexelUnits = 0;
    currentTextureIndices = currentTextureTypes = NULL;
	boundTextureIndices = boundTextureTypes = NULL;
	lockedTexelUnits = NULL;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) startup
{
    GLint numberSTU = 0;
    GLint maxNumberVTU = 0;
	glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &numberSTU);
	glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &maxNumberVTU);

    numberOfSuppertedTexelUnits = (uint32_t)(MAX(4, numberSTU));
    maximumNumberOfVertexTexelUnits = (uint32_t)(MAX(4, maxNumberVTU));

    NPLOG(@"Maximum Texel Units: %d", numberSTU);
	NPLOG(@"Maximum Vertex Texel Units: %d", maxNumberVTU);

	currentTextureIndices = ALLOC_ARRAY(GLuint, numberOfSuppertedTexelUnits);
	boundTextureIndices   = ALLOC_ARRAY(GLuint, numberOfSuppertedTexelUnits);
	currentTextureTypes   = ALLOC_ARRAY(GLenum, numberOfSuppertedTexelUnits);
	boundTextureTypes     = ALLOC_ARRAY(GLenum, numberOfSuppertedTexelUnits);
	lockedTexelUnits      = ALLOC_ARRAY(BOOL, numberOfSuppertedTexelUnits);

	for ( uint32_t i = 0; i < numberOfSuppertedTexelUnits; i++ )
	{
		currentTextureIndices[i] = 0;
		boundTextureIndices[i]   = 0;

		currentTextureTypes[i] = GL_TEXTURE_2D;
		boundTextureTypes[i]   = GL_TEXTURE_2D;

		lockedTexelUnits[i] = NO;
	}
}

- (void) shutdown
{
    SAFE_FREE(currentTextureIndices);
    SAFE_FREE(boundTextureIndices);
    SAFE_FREE(currentTextureTypes);
    SAFE_FREE(boundTextureTypes);
    SAFE_FREE(lockedTexelUnits);
}

- (void) lock
{
    locked = YES;
}

- (void) unlock
{
    locked = NO;
}

- (void) clear
{
	for ( uint32_t i = 0; i < numberOfSuppertedTexelUnits; i++ )
	{
		glActiveTexture(GL_TEXTURE0 + i);
		glBindTexture(boundTextureTypes[i], 0);

		boundTextureIndices[i]   = 0;
		boundTextureTypes[i]     = GL_TEXTURE_2D;
		currentTextureIndices[i] = 0;
		currentTextureTypes[i]   = GL_TEXTURE_2D;
		lockedTexelUnits[i]      = NO;
	}

	glActiveTexture(GL_TEXTURE0);    
}

- (void) reset
{
    if ( locked == YES )
    {
        return;
    }

	for ( uint32_t i = 0; i < numberOfSuppertedTexelUnits; i++ )
	{
		if (lockedTexelUnits[i] == NO)
		{
			currentTextureIndices[i] = 0;
			currentTextureTypes[i]   = GL_TEXTURE_2D;
		}
	}

	glActiveTexture(GL_TEXTURE0);
}

- (void) lockTexelUnit:(const uint32_t)texelUnit
{
    if ( texelUnit < numberOfSuppertedTexelUnits )
    {
        lockedTexelUnits[texelUnit] = YES;
    }
}

- (void) unlockTexelUnit:(const uint32_t)texelUnit
{
    if ( texelUnit < numberOfSuppertedTexelUnits )
    {
        lockedTexelUnits[texelUnit] = NO;
    }
}

- (void) setNoTexture:(const uint32_t)texelUnit
{
	if ( locked )
	{
		return;
	}

    if ( texelUnit >= numberOfSuppertedTexelUnits )
    {
        return;
    }
    
	if (lockedTexelUnits[texelUnit] == YES)
	{
		return;
	}

	currentTextureIndices[texelUnit] = 0;
	currentTextureTypes[texelUnit]   = GL_TEXTURE_2D;
}

- (void) setTexture:(id <NPPTexture>)texture texelUnit:(const uint32_t)texelUnit
{
	if ( locked )
	{
		return;
	}

    if ( texelUnit >= numberOfSuppertedTexelUnits )
    {
        return;
    }
    
	if (lockedTexelUnits[texelUnit] == YES)
	{
		return;
	}

	if ( texture != nil )
	{
		currentTextureIndices[texelUnit] = [ texture glID ];
		currentTextureTypes[texelUnit]   = [ texture glTarget ];
	}
	else
	{
		currentTextureIndices[texelUnit] = 0;
		currentTextureTypes[texelUnit]   = GL_TEXTURE_2D;
	}
}

- (void) setTextureImmediately:(id <NPPTexture>)texture
{
	glActiveTexture(GL_TEXTURE0);
	glBindTexture([ texture glTarget ], [ texture glID ]);

	currentTextureIndices[0] = [ texture glID ];
	currentTextureTypes[0]   = [ texture glTarget ];
}

- (void) restoreOriginalTextureImmediately
{
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(boundTextureTypes[0], boundTextureIndices[0]);

	currentTextureIndices[0] = boundTextureIndices[0];
	currentTextureTypes[0]   = boundTextureTypes[0];
}

- (void) activate
{
    [ self activate:NO ];
}

- (void) activate:(BOOL)force
{
	if ( locked == YES )
	{
		return;
	}

	for ( uint32_t i = 0; i < numberOfSuppertedTexelUnits; i++ )
	{
		if ((currentTextureIndices[i] != boundTextureIndices[i]) || (force == YES))
		{
			glActiveTexture(GL_TEXTURE0 + i);
			glBindTexture(currentTextureTypes[i], currentTextureIndices[i]);

			boundTextureIndices[i] = currentTextureIndices[i];
			boundTextureTypes[i]   = currentTextureTypes[i];
		}
	}

	glActiveTexture(GL_TEXTURE0);
}

@end

