#import "NPDevilTexture.h"

void npimage_initialise()
{
    ilInit();
    iluInit();
    ilutInit();
}

@implementation NPDevilTexture

+ (void) initIlutGL
{
    ilutRenderer(ILUT_OPENGL);
}

+ (GLuint) glTextureFromFile: (NSString *) fileName;
{
    if ((ilGetInteger(IL_VERSION_NUM) < IL_VERSION) ||
        (iluGetInteger(ILU_VERSION_NUM) < ILU_VERSION) ||
        (ilutGetInteger(ILUT_VERSION_NUM) < ILUT_VERSION)) 
    {
        NSLog(@"Devil wrong version");
    }

    ILuint ilImageHandle;

    ilGenImages(1, &ilImageHandle);
    ilBindImage(ilImageHandle);
    const char * brak = [ fileName cString ];
    ilLoadImage(brak);
    iluFlipImage();

    GLuint glImageHandle = ilutGLBindMipmaps();

    ilDeleteImages(1, &ilImageHandle);

    return glImageHandle;
}

@end
