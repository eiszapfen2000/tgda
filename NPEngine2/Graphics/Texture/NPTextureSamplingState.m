#import "Core/Basics/NpMemory.h"
#import "Log/NPLog.h"
#import "NPSamplerObject.h"
#import "NPTextureSamplingState.h"

@implementation NPTextureSamplingState

- (id) init
{
    return [ self initWithName:@"" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    locked = NO;
    numberOfSuppertedTexelUnits = 0;
	currentSamplerIndices = boundSamplerIndices = NULL;
	lockedSamplers = NULL;

    return self;
}

- (void) dealloc
{
    // in case shutdown is not called,
    // free all arrays here
    SAFE_FREE(currentSamplerIndices);
    SAFE_FREE(boundSamplerIndices);
    SAFE_FREE(lockedSamplers);

    [ super dealloc ];
}

- (void) startup
{
    GLint numberSTU = 0;
    glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &numberSTU);

    // this is to prevent crashs in case the driver
    // returns -1
    numberOfSuppertedTexelUnits = (uint32_t)(MAX(4, numberSTU));

	currentSamplerIndices = ALLOC_ARRAY(GLuint, numberOfSuppertedTexelUnits);
	boundSamplerIndices   = ALLOC_ARRAY(GLuint, numberOfSuppertedTexelUnits);
	lockedSamplers        = ALLOC_ARRAY(BOOL, numberOfSuppertedTexelUnits);

	for ( uint32_t i = 0; i < numberOfSuppertedTexelUnits; i++ )
	{
		currentSamplerIndices[i] = 0;
		boundSamplerIndices[i]   = 0;

		lockedSamplers[i] = NO;
	}
}

- (void) shutdown
{
    SAFE_FREE(currentSamplerIndices);
    SAFE_FREE(boundSamplerIndices);
    SAFE_FREE(lockedSamplers);
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
		glBindSampler(i, 0);

		boundSamplerIndices[i]   = 0;
		currentSamplerIndices[i] = 0;
		lockedSamplers[i]        = NO;
	}  
}

- (void) reset
{
    if ( locked == YES )
    {
        return;
    }

	for ( uint32_t i = 0; i < numberOfSuppertedTexelUnits; i++ )
	{
		if (lockedSamplers[i] == NO)
		{
			currentSamplerIndices[i] = 0;
		}
	}
}

- (void) lockSamplerAtTexelUnit:(const uint32_t)texelUnit
{
    if ( texelUnit < numberOfSuppertedTexelUnits )
    {
        lockedSamplers[texelUnit] = YES;
    }
}

- (void) unlockSamplerAtTexelUnit:(const uint32_t)texelUnit
{
    if ( texelUnit < numberOfSuppertedTexelUnits )
    {
        lockedSamplers[texelUnit] = NO;
    }
}

- (void) setSampler:(NPSamplerObject *)sampler texelUnit:(const uint32_t)texelUnit
{
	if ( locked )
	{
		return;
	}

    if ( texelUnit >= numberOfSuppertedTexelUnits )
    {
        return;
    }
    
	if (lockedSamplers[texelUnit] == YES)
	{
		return;
	}

	if ( sampler != nil )
	{
		currentSamplerIndices[texelUnit] = [ sampler glID ];
	}
	else
	{
		currentSamplerIndices[texelUnit] = 0;
	}
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
		if ((currentSamplerIndices[i] != boundSamplerIndices[i]) || (force == YES))
		{
			glBindSampler(i, currentSamplerIndices[i]);

			boundSamplerIndices[i] = currentSamplerIndices[i];
		}
	}
}

@end

