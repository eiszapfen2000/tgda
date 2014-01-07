#import <Foundation/NSString.h>
#import "NPEngineGraphicsErrors.h"

NSString * const NPVertexArrayVertexStreamEmpty = @"Vertex stream is empty.";
NSString * const NPVertexArrayIndexStreamEmpty = @"Index stream is empty.";
NSString * const NPVertexArrayVertexStreamTooLarge = @"Vertex stream exceeds 2GB limit.";
NSString * const NPVertexArrayIndexStreamTooLarge = @"Index stream exceeds 2GB limit.";

NSString * const NPVertexArrayStreamMismatch
    = @"Stream has not the same number of vertices as other streams.";

