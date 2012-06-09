#import "NPStencilTestState.h"

@implementation NPStencilTestState

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    writeEnabled        = YES;
    defaultWriteEnabled = YES;
    currentWriteEnabled = NO;

    comparisonFunction        = NpComparisonNotEqual;
    defaultComparisonFunction = NpComparisonNotEqual;
    currentComparisonFunction = NpComparisonEqual;

    referenceValue = 0;
    defaultReferenceValue = 0;
    currentReferenceValue = 1;

    comparisonMask = ~0u;
    defaultComparisonMask = ~0u;
    currentComparisonMask = 0;

    operationOnStencilTestFail = NpStencilKeepValue;
    defaultOperationOnStencilTestFail = NpStencilKeepValue;
    currentOperationOnStencilTestFail = NpStencilIncrementValue;

    operationOnDepthTestFail = NpStencilKeepValue;
    defaultOperationOnDepthTestFail = NpStencilKeepValue;
    currentOperationOnDepthTestFail = NpStencilIncrementValue;

    operationOnDepthTestPass = NpStencilKeepValue;
    defaultOperationOnDepthTestPass = NpStencilKeepValue;
    currentOperationOnDepthTestPass = NpStencilIncrementValue;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) enabled
{
    return enabled;
}

- (BOOL) defaultEnabled
{
    return defaultEnabled;
}

- (BOOL) writeEnabled
{
    return writeEnabled;
}

- (BOOL) defaultWriteEnabled
{
    return defaultWriteEnabled;
}

- (NpComparisonFunction) comparisonFunction
{
    return comparisonFunction;
}

- (NpComparisonFunction) defaultComparisonFunction
{
    return defaultComparisonFunction;
}

- (int32_t) referenceValue
{
    return referenceValue;
}

- (int32_t) defaultReferenceValue
{
    return defaultReferenceValue;
}

- (uint32_t) comparisonMask
{
    return comparisonMask;
}

- (uint32_t) defaultComparisonMask
{
    return defaultComparisonMask;
}

- (NpStencilOperation) operationOnStencilTestFail
{
    return operationOnStencilTestFail;
}

- (NpStencilOperation) defaultOperationOnStencilTestFail
{
    return defaultOperationOnStencilTestFail;
}

- (NpStencilOperation) operationOnDepthTestFail
{
    return operationOnDepthTestFail;
}

- (NpStencilOperation) defaultOperationOnDepthTestFail
{
    return defaultOperationOnDepthTestFail;
}

- (NpStencilOperation) operationOnDepthTestPass
{
    return operationOnDepthTestPass;
}

- (NpStencilOperation) defaultOperationOnDepthTestPass
{
    return defaultOperationOnDepthTestPass;
}

- (void) setEnabled:(BOOL)newEnabled
{
    if ( [ super changeable ] == YES )
    {
        enabled = newEnabled;
    }
}

- (void) setDefaultEnabled:(BOOL)newDefaultEnabled
{
    defaultEnabled = newDefaultEnabled;
}

- (void) setWriteEnabled:(BOOL)newWriteEnabled
{
    if ( [ super changeable ] == YES )
    {
        writeEnabled = newWriteEnabled;
    }
}

- (void) setDefaultWriteEnabled:(BOOL)newDefaultWriteEnabled
{
    defaultWriteEnabled = newDefaultWriteEnabled;
}

- (void) setComparisonFunction:(NpComparisonFunction)newComparisonFunction
{
    if ( [ super changeable ] == YES )
    {
        comparisonFunction = newComparisonFunction;
    }
}

- (void) setDefaultComparisonFunction:(NpComparisonFunction)newDefaultComparisonFunction
{
    defaultComparisonFunction = newDefaultComparisonFunction;
}

- (void) setReferenceValue:(int32_t)newReferenceValue
{
    if ( [ super changeable ] == YES )
    {
        referenceValue = newReferenceValue;
    }
}

- (void) setDefaultReferenceValue:(int32_t)newDefaultReferenceValue
{
    defaultReferenceValue = newDefaultReferenceValue;
}

- (void) setComparisonMask:(uint32_t)newComparisonMask
{
    if ( [ super changeable ] == YES )
    {
        comparisonMask = newComparisonMask;
    }
}

- (void) setDefaultComparisonMask:(uint32_t)newDefaultComparisonMask
{
    defaultComparisonMask = newDefaultComparisonMask;
}

- (void) setOperationOnStencilTestFail:(NpStencilOperation)newOperationOnStencilTestFail
{
    if ( [ super changeable ] == YES )
    {
        operationOnStencilTestFail = newOperationOnStencilTestFail;
    }
}

- (void) setDefaultOperationOnStencilTestFail:(NpStencilOperation)newDefaultOperationOnStencilTestFail
{
    defaultOperationOnStencilTestFail = newDefaultOperationOnStencilTestFail;
}

- (void) setOperationOnDepthTestFail:(NpStencilOperation)newOperationOnDepthTestFail
{
    if ( [ super changeable ] == YES )
    {
        operationOnDepthTestFail = newOperationOnDepthTestFail;
    }
}

- (void) setDefaultOperationOnDepthTestFail:(NpStencilOperation)newDefaultOperationOnDepthTestFail
{
    defaultOperationOnDepthTestFail = newDefaultOperationOnDepthTestFail;
}

- (void) setOperationOnDepthTestPass:(NpStencilOperation)newOperationOnDepthTestPass
{
    if ( [ super changeable ] == YES )
    {
        operationOnDepthTestPass = newOperationOnDepthTestPass;
    }
}

- (void) setDefaultOperationOnDepthTestPass:(NpStencilOperation)newDefaultOperationOnDepthTestPass
{
    defaultOperationOnDepthTestPass = newDefaultOperationOnDepthTestPass;
}

- (void) activate
{
    if ( [ super changeable ] == NO )
    {
         return;
    }

    if ( currentlyEnabled != enabled )
    {
        currentlyEnabled = enabled;

        if ( enabled == YES )
        {
            glEnable(GL_STENCIL_TEST);
        }
        else
        {
            glDisable(GL_STENCIL_TEST);
        }
    }

    if ( currentWriteEnabled != writeEnabled )
    {
        currentWriteEnabled = writeEnabled;
        glStencilMask(~0u);
    }

    if ( enabled == YES )
    {
        if ( currentComparisonFunction != comparisonFunction 
             || currentReferenceValue  != referenceValue
             || currentComparisonMask  != comparisonMask )
        {
            currentComparisonFunction = comparisonFunction;
            currentReferenceValue     = referenceValue;
            currentComparisonMask     = comparisonMask;

            GLenum comparison
                = getGLComparisonFunction(currentComparisonFunction);

            glStencilFunc(comparison, currentReferenceValue, currentComparisonMask);
        }

        if ( currentOperationOnStencilTestFail  != operationOnStencilTestFail
             || currentOperationOnDepthTestFail != operationOnDepthTestFail
             || currentOperationOnDepthTestPass != operationOnDepthTestPass )
        {
            currentOperationOnStencilTestFail = operationOnStencilTestFail;
            currentOperationOnDepthTestFail   = operationOnDepthTestFail;
            currentOperationOnDepthTestPass   = operationOnDepthTestPass;

            const GLenum sfail = getGLStencilOperation(currentOperationOnStencilTestFail);
            const GLenum dfail = getGLStencilOperation(currentOperationOnDepthTestFail);
            const GLenum dpass = getGLStencilOperation(currentOperationOnDepthTestPass);

            glStencilOp(sfail, dfail, dpass);
        }
    }
}

- (void) deactivate
{
    if ( [ super changeable ] == YES )
    {
        [ self reset ];
        [ self activate ];
    }
}

- (void) reset
{
    if ( [ super changeable ] == YES )
    {
        enabled            = defaultEnabled;
        writeEnabled       = defaultWriteEnabled;
        comparisonFunction = defaultComparisonFunction;
        referenceValue     = defaultReferenceValue;
        comparisonMask     = defaultComparisonMask;

        operationOnStencilTestFail = defaultOperationOnStencilTestFail;
        operationOnDepthTestFail = defaultOperationOnDepthTestFail;
        operationOnDepthTestPass = defaultOperationOnDepthTestPass;
    }
}


@end
