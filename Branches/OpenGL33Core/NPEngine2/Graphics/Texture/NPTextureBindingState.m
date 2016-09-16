#import "Core/Basics/NpMemory.h"
#import "Log/NPLog.h"
#import "NPTextureBindingState.h"

@implementation NPTextureBindingState

- (id) init
{
    return [ self initWithName:@"" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    locked = NO;
    numberOfSuppertedTexelUnits = maximumNumberOfVertexTexelUnits
        = maximumNumberOfGeometryTexelUnits = maximumNumberOfFragmentTexelUnits = 0;
    currentTextureIndices = currentTextureTypes = NULL;
	boundTextureIndices = boundTextureTypes = NULL;
	lockedTexelUnits = NULL;

    return self;
}

- (void) dealloc
{
    // in case shutdown is not called,
    // free all arrays here
    SAFE_FREE(currentTextureIndices);
    SAFE_FREE(boundTextureIndices);
    SAFE_FREE(currentTextureTypes);
    SAFE_FREE(boundTextureTypes);
    SAFE_FREE(lockedTexelUnits);

    [ super dealloc ];
}

- (void) startup
{
    GLint numberSTU = 0;
    GLint maxNumberVTU = 0;
    GLint maxNumberGTU = 0;
    GLint maxNumberFTU = 0;
    glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &numberSTU);
	glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &maxNumberVTU);
    glGetIntegerv(GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS, &maxNumberGTU);
	glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &maxNumberFTU);

    // this is to prevent crashs in case the driver
    // returns -1
    numberOfSuppertedTexelUnits = (uint32_t)(MAX(4, numberSTU));
    maximumNumberOfVertexTexelUnits = (uint32_t)(MAX(4, maxNumberVTU));
    maximumNumberOfGeometryTexelUnits = (uint32_t)(MAX(4, maxNumberGTU));
    maximumNumberOfFragmentTexelUnits = (uint32_t)(MAX(4, maxNumberFTU));

    // log the values the driver returns
    NPLOG(@"Maximum Texel Units: %d", numberSTU);
	NPLOG(@"Maximum Vertex Texel Units: %d", maxNumberVTU);
	NPLOG(@"Maximum Geometry Texel Units: %d", maxNumberGTU);
	NPLOG(@"Maximum Fragment Texel Units: %d", maxNumberFTU);

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

- (uint32_t) numberOfSuppertedTexelUnits
{
	return numberOfSuppertedTexelUnits;
}

- (uint32_t) maximumNumberOfVertexTexelUnits
{
	return maximumNumberOfVertexTexelUnits;
}

- (uint32_t) maximumNumberOfGeometryTexelUnits
{
	return maximumNumberOfGeometryTexelUnits;
}

- (uint32_t) maximumNumberOfFragmentTexelUnits
{
	return maximumNumberOfFragmentTexelUnits;
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

