#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class NPEffect;

#ifndef SUX2_SAMPLER_COUNT
#define SUX2_SAMPLER_COUNT 8
#endif

@interface NPSUX2MaterialInstance : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NSMutableArray * textures;
    NPEffect * effect;
    NSString * techniqueName;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPEffect *) effect;
- (NSString *) techniqueName;

- (void) addEffectFromFile:(NSString *)fileName;
- (void) setTechniqueName:(NSString *)newTechniqueName;

- (void) addTexture2DWithName:(NSString *)samplerName
                     fromFile:(NSString *)fileName
                         sRGB:(BOOL)sRGB
                             ;

- (void) activate;

@end
