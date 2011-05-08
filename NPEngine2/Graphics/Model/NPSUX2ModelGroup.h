#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPSUX2ModelLOD;

@interface NPSUX2ModelGroup : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NpPrimitveType primitiveType;
    int32_t firstIndex;
    int32_t lastIndex;
    int32_t materialInstanceIndex;

    NPSUX2ModelLOD * lod;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPSUX2ModelLOD *) lod;
- (void) setLod:(NPSUX2ModelLOD *)newLod;

- (void) render;

@end
