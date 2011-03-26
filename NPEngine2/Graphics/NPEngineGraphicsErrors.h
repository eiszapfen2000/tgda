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
    NPEngineGraphicsTextureUnableToLoadImage = 2060,
    NPEngineGraphicsShaderGLSLCompilationError = 2096,
    NPEngineGraphicsEffectTechniqueGLSLLinkError = 2097,
    NPEngineGraphicsEffectTechniqueShaderMissing = 2098,
    NPEngineGraphicsEffectTechniqueShaderCorrupt = 2099,
    NPEngineGraphicsFBOError = 3000
};

#endif
