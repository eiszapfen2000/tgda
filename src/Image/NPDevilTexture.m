#import "NPDevilTexture.h"

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

    if ( !ilLoadImage([ fileName cString ]) )
    {
        return -1;
    }

    iluFlipImage();

    GLuint glImageHandle = ilutGLBindMipmaps();

    ilDeleteImages(1, &ilImageHandle);

    return glImageHandle;
}

@end
