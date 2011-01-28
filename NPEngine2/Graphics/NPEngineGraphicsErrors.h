#ifndef NPENGINEGRAPHICSERRORS_H_
#define NPENGINEGRAPHICSERRORS_H_

enum
{
    NPEngineGraphicsErrorMinimum = 2048,
    NPEngineGraphicsErrorMaximum = 3072,
    NPEngineGraphicsGLEWError = 2048,
    NPEngineGraphicsGLError = 2049,
    NPEngineGraphicsDevILError = 2050,
    NPEngineGraphicsImageHasInvalidSize = 2051,
    NPEngineGraphicsImageHasUnknownFormat = 2052,
    NPEngineGraphicsShaderGLSLCompilationError = 2096,
    NPEngineGraphicsShaderConfigurationGLSLLinkError = 2097,
    NPEngineGraphicsShaderConfigurationShaderMissing = 2098,
    NPEngineGraphicsShaderConfigurationShaderCorrupt = 2099,
};

#endif
