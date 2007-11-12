#import "Core/NPObject.h"
#import <NPPixelFormat.h>

#import <IL/il.h>
#import <IL/ilu.h>
#import <IL/ilut.h>

@interface NPDevilTexture : NPObject

+ (void) initIlutGL;
+ (GLuint) glTextureFromFile: (NSString *) fileName;

@end
