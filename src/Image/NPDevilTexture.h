#import "Core/NPObject.h"
#import <NPPixelFormat.h>

#import <IL/il.h>
#import <IL/ilu.h>
#import <IL/ilut.h>

void npimage_initialise();

@interface NPDevilTexture : NPObject

+ (void) initIlutGL;
+ (GLuint) glTextureFromFile: (NSString *) fileName;

@end
