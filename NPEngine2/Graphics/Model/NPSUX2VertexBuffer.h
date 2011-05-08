#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class NPVertexArray;

@interface NPSUX2VertexBuffer : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NPVertexArray * vertexArray;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) renderWithPrimitiveType:(const NpPrimitveType)primitveType
                      firstIndex:(const int32_t)firstIndex
                       lastIndex:(const int32_t)lastIndex
                                ;

@end
